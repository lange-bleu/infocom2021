import os
import glob
import torch
import librosa
import argparse

from utils.audio import Audio
from utils.hparams import HParam
from model.model import VoiceFilter
from model.embedder import SpeechEmbedder


def main(args):
    hp = HParam(args['config'])

    with torch.no_grad():
        model = VoiceFilter(hp).cuda()
        chkpt_model = torch.load(args['checkpoint_path'])['model']
        model.load_state_dict(chkpt_model)
        model.eval()

        embedder = SpeechEmbedder(hp).cuda()
        chkpt_embed = torch.load(args['embedder_path'])
        embedder.load_state_dict(chkpt_embed)
        embedder.eval()

        audio = Audio(hp)
        dvec_wav, _ = librosa.load(args['reference_file'], sr=16000)
        dvec_mel = audio.get_mel(dvec_wav)
        dvec_mel = torch.from_numpy(dvec_mel).float().cuda()
        dvec = embedder(dvec_mel)
        dvec = dvec.unsqueeze(0)

        mixed_wav, _ = librosa.load(args['mixed_file'], sr=16000)
        mag, phase = audio.wav2spec(mixed_wav)
        mag = torch.from_numpy(mag).float().cuda()

        mag = mag.unsqueeze(0)
        mask = model(mag, dvec)
        est_mag = mag * mask

        est_mag = est_mag[0].cpu().detach().numpy()
        # est_wav = audio.spec2wav(est_mag, phase)

        # os.makedirs(args['out_dir'], exist_ok=True)
        # out_path = os.path.join(args['out_dir'], 'result.wav')
        # librosa.output.write_wav(out_path, est_wav, sr=16000)
        return audio.spec2wav(est_mag, phase)
