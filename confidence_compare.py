from datasets.eva_dataloader_focus import create_dataloader
import wavio
import argparse
from utils.hparams import HParam
import os
import glob
import torch
import librosa
import argparse

from utils.audio import Audio
from model.model import VoiceFilter
from model.embedder import SpeechEmbedder
from utils.speech2text import speech_2_text
from utils.evaluation import tensor_normalize
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np


def wav_to_embedding(wav, embedder):
    """
    This function takes wav as input, then produce the embedding for given wav
    Returns:
    embedding as numpy array
    """
    wav_mel = audio.get_mel(wav)
    wav_ref_mel = torch.from_numpy(wav_mel).float().cuda()
    wav_dvec = embedder(wav_ref_mel)
    wav_dvector = wav_dvec.unsqueeze(0)
    wav_dvector = wav_dvector.cpu().detach().numpy()

    return wav_dvector


def init_badwav():
    wer = 1
    mer = 1
    wil = 1
    pesq_value = 0
    sdr = [-10]
    sir = [np.inf]
    sar = [-10]
    return wer, mer, wil, pesq_value, sdr, sir, sar


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--base_dir', type=str, default='.',
                        help="Root directory of run.")
    parser.add_argument('-c', '--config', type=str, required=True,
                        help="yaml file for configuration")
    parser.add_argument('-e', '--embedder_path', type=str, required=True,
                        help="path of embedder model pt file")
    parser.add_argument('--checkpoint_path', type=str, default=None,
                        help="path of checkpoint pt file")
    parser.add_argument('--voice_filter', type=str, default=None,
                        help="path of checkpoint pt file of voice_filter system")
    parser.add_argument('-m', '--model', type=str, required=True,
                        help="Name of the model. Used for both logging and saving checkpoints.")
    parser.add_argument('-g', '--gpu', type=int, required=True, default='1',
                        help="ID of the selected gpu. Used for gpu selection.")
    parser.add_argument('-o', '--out_dir', type=str, required=True,
                        help="out directory of result.wav")
    # parser.add_argument('-x', '--xlsx', type=str, required=True,
    #                     help="result name of xlsx file")
    args = parser.parse_args()

    hp = HParam(args.config)
    root_dir_test = hp.data.test_dir
    alldirs = [x[0] for x in os.walk(root_dir_test)]
    # dirs = [leaf for leaf in alldirs if leaf.split('/')[-1].isnumeric()]
    dirs = [leaf for leaf in alldirs if leaf.split('/')[-1] == 'conversation' or leaf.split('/')[-1]== '0dB']

    speaker_count = 0
    six_Results = {}  # { noise1: [{conf1:x, conf2:x, conf3:x}, {conf1:x, conf2:x, conf3:x}, ... , {}], noise2: []}
    for dir in dirs:
        print(dir)
        exit(0)
        tree = dir.split('/')
        if tree[-1] == 'conversation':
            typen = 'conversation'
        elif tree[-2] == 'joint':
            typen = 'joint'
        elif tree[4] == 'babble':
            typen = 'babble'
        elif tree[4] == 'factory2':
            typen = 'factory2'
        elif tree[4] == 'leopard':
            typen = 'leopard'
        elif tree[4] == 'volvo':
            typen = 'volvo'
        else:
            typen = 'gun'
        if typen not in six_Results.keys():
            six_Results[typen] = []
        print(typen)
        hp.data.test_dir = dir
        testloader = create_dataloader(hp, args, train=False)
        for batch in testloader:
            # length of batch is 1, set in dataloader
            ref_mel, expected_focused_wav, mixed_wav, expected_focused_mag, mixed_mag, mixed_phase, dvec_path, expected_focused_wav_path, mixed_wav_path = \
                batch[0]
            # print("expected_focused: {}".format(expected_focused_wav_path))
            # print("Mixed: {}".format(mixed_wav_path))
            model = VoiceFilter(hp).cuda()
            chkpt_model = torch.load(args.checkpoint_path)['model']
            model.load_state_dict(chkpt_model)
            model.eval()

            vf_model = VoiceFilter(hp).cuda()
            vf_model_chkpt = torch.load(args.voice_filter)['model']
            vf_model.load_state_dict(vf_model_chkpt)
            vf_model.eval()

            embedder = SpeechEmbedder(hp).cuda()
            chkpt_embed = torch.load(args.embedder_path)
            embedder.load_state_dict(chkpt_embed)
            embedder.eval()

            audio = Audio(hp)
            dvec_wav, _ = librosa.load(dvec_path, sr=16000)
            ref_mel = audio.get_mel(dvec_wav)
            ref_mel = torch.from_numpy(ref_mel).float().cuda()
            dvec = embedder(ref_mel)
            dvec = dvec.unsqueeze(0)  # (1, 256)

            mixed_wav, _ = librosa.load(mixed_wav_path, sr=16000)
            mixed_mag, mixed_phase = audio.wav2spec(mixed_wav)
            mixed_mag = torch.from_numpy(mixed_mag).float().cuda()

            mixed_mag = mixed_mag.unsqueeze(0)

            shadow_mag = model(mixed_mag, dvec)
            # shadow_mag.size() = [1, 301, 601]
            vf_mask = vf_model(mixed_mag, dvec)
            vf_recorded_mag = mixed_mag * vf_mask

            recorded_mag = tensor_normalize(mixed_mag + shadow_mag)
            recorded_mag = recorded_mag[0].cpu().detach().numpy()
            mixed_mag = mixed_mag[0].cpu().detach().numpy()
            expected_focused_mag = expected_focused_mag[0].cpu().detach().numpy()
            # recorded_mag = recorded_mag[0].cpu().detach().numpy()
            shadow_mag = shadow_mag[0].cpu().detach().numpy()
            shadow_wav = audio.spec2wav(shadow_mag, mixed_phase)

            # scale is frequency pass to time domain, used on wav signal normalization
            recorded_wav1 = audio.spec2wav(recorded_mag, mixed_phase)  # path 1
            enhanced_wav = (mixed_wav + 100 * shadow_wav) / max(abs(mixed_wav + 100 * shadow_wav))  # path 2

            #################################################################################
            #  Voice filter model
            # vf_mask = vf_model(mixed_mag, dvec)
            vf_recorded_mag = vf_recorded_mag[0].cpu().detach().numpy()
            vf_recorded_wav = audio.spec2wav(vf_recorded_mag, mixed_phase)
            #################################################################################

            os.makedirs(args.out_dir, exist_ok=True)
            purified1 = os.path.join(args.out_dir, 'result1.wav')
            # purified2 = os.path.join(args.out_dir, 'result2.wav')
            # purified3 = os.path.join(args.out_dir, 'result3.wav')
            purified4 = os.path.join(args.out_dir, 'vf_result.wav')
            expected_focused_path = os.path.join(args.out_dir, 'expected_focused.wav')
            mixed_path = os.path.join(args.out_dir, 'mixed.wav')
            # original mixed wav and expected_focused wav are not PCM, cannot be read by google cloud
            wavio.write(purified1, recorded_wav1, 16000, sampwidth=2)  # frequency +
            # wavio.write(purified2, shadow_wav, 16000, sampwidth=2)  # est noise
            # wavio.write(purified3, enhanced_wav, 16000, sampwidth=2)  # mix + est noise
            wavio.write(purified4, vf_recorded_wav, 16000, sampwidth=2)
            wavio.write(expected_focused_path, expected_focused_wav, 16000, sampwidth=2)
            wavio.write(mixed_path, mixed_wav, 16000, sampwidth=2)
            # librosa.output.write_wav(out_path, enhanced_wav, sr=16000)
            dvec = dvec.cpu().detach().numpy()  # the reference embedding
            mixed_dvec = wav_to_embedding(mixed_wav, embedder)

            purified1_dvec = wav_to_embedding(recorded_wav1, embedder)
            # purified2_dvec = wav_to_embedding(shadow_wav, embedder)
            # purified3_dvec = wav_to_embedding(enhanced_wav, embedder)
            vf_dvec = wav_to_embedding(vf_recorded_wav, embedder)

            purified1_conf = cosine_similarity(dvec, purified1_dvec)[0][0]
            # purified2_conf = cosine_similarity(dvec, purified2_dvec)[0][0]
            # purified3_conf = cosine_similarity(dvec, purified3_dvec)[0][0]
            vf_conf = cosine_similarity(dvec, vf_dvec)[0][0]
            mixed_conf = cosine_similarity(dvec, mixed_dvec)[0][0]
            confidents = {"recorded_our_model":purified1_conf, "mixed": mixed_conf, "voice_filter":vf_conf}
            six_Results[typen].append(confidents)
            # try:
            #     [wer, mer, wil], pesq_value, sdr, sir, sar = speech_2_text(expected_focused_path, purified1, 'google')
            # except TypeError:
            #     wer, mer, wil, pesq_value, sdr, sir, sar = init_badwav()
            #     # print(
            #     #     "Spectrogram: wer: {0}, mer: {1}, wil: {2}, pesq: {3}, sdr: {4}".format(wer, mer, wil, pesq_value, sdr))
            # r1 = {"mixed_path": mixed_wav_path, "expected_focused_path": expected_focused_wav_path,
            #       "wer": wer, "mer": mer, "wil": wil, "pesq": pesq_value, "sdr": sdr[0], "sir": sir[0], "sar": sar[0],
            #       "confidence": purified1_conf}
            # result_focused1.append(r1)
            #
            #
            # try:
            #     [wer, mer, wil], pesq_value, sdr, sir, sar = speech_2_text(expected_focused_path, mixed_path, 'google')
            # except TypeError:
            #     wer, mer, wil, pesq_value, sdr, sir, sar = init_badwav()
            # r4 = {"mixed_path": mixed_wav_path, "expected_focused_path": expected_focused_wav_path,
            #       "wer": wer, "mer": mer, "wil": wil, "pesq": pesq_value, "sdr": sdr[0], "sir": sir[0], "sar": sar[0],
            #       "confidence": mixed_conf}
            # result_mixed.append(r4)

        # focus_result_expect_focused = os.path.join(dir, 'focus_expect_focused.xlsx')
        #
    writer = pd.ExcelWriter('confident_result.xlsx', engine='xlsxwriter', options={'strings_to_urls': False})
    df_joint = pd.DataFrame(data=six_Results['joint'])
    df_conv = pd.DataFrame(data=six_Results['conversation'])
    df_babble = pd.DataFrame(data=six_Results['babble'])
    df_factory = pd.DataFrame(data=six_Results['factory2'])
    df_leopard = pd.DataFrame(data=six_Results['leopard'])
    df_gun = pd.DataFrame(data=six_Results['gun'])
    df_volvo = pd.DataFrame(data=six_Results['volvo'])

    df_joint.to_excel(writer, sheet_name='joint')
    df_conv.to_excel(writer, sheet_name='conversation')
    df_babble.to_excel(writer, sheet_name='babble')
    df_factory.to_excel(writer, sheet_name='factory')
    df_leopard.to_excel(writer, sheet_name='leopard')
    df_gun.to_excel(writer, sheet_name='gun')
    df_volvo.to_excel(writer, sheet_name='volvo')

    writer.close()
