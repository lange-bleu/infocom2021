import os
# os.environ["CUDA_VISIBLE_DEVICES"] = "1,2,3,4,5,6,7"
import glob
import torch
import librosa
import argparse

from utils.audio import Audio
from utils.hparams import HParam
from model.model import VoiceFilter
from model.embedder import SpeechEmbedder
from utils.evaluation import tensor_normalize


def main(args, hp):
    with torch.no_grad():
        model = VoiceFilter(hp).cuda()
        chkpt_model = torch.load(args.checkpoint_path)['model']
        model.load_state_dict(chkpt_model)
        model.eval()

        embedder = SpeechEmbedder(hp).cuda()
        chkpt_embed = torch.load(args.embedder_path)
        embedder.load_state_dict(chkpt_embed)
        embedder.eval()

        audio = Audio(hp)
        ref_wav, _ = librosa.load(args.reference_file, sr=16000)
        ref_mel = audio.get_mel(ref_wav)
        ref_mel = torch.from_numpy(ref_mel).float().cuda()
        dvec = embedder(ref_mel)
        dvec = dvec.unsqueeze(0)

        mixed_wav, _ = librosa.load(args.mixed_file, sr=16000)
        mixed_mag, mixed_phase = audio.wav2spec(mixed_wav)
        mixed_mag = torch.from_numpy(mixed_mag).float().cuda()

        mixed_mag = mixed_mag.unsqueeze(0)
        shadow_mag = model(mixed_mag, dvec)

        shadow_mag = shadow_mag[0].cpu().detach().numpy()
        recorded_mag = tensor_normalize(mixed_mag.cpu() + shadow_mag)
        recorded_mag = recorded_mag[0].cpu().detach().numpy()
        recorded_wav = audio.spec2wav(recorded_mag, mixed_phase)

        os.makedirs(args.out_dir, exist_ok=True)
        out_path = os.path.join(args.out_dir, 'result.wav')
        librosa.output.write_wav(out_path, recorded_wav, sr=16000)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config', type=str, required=True,
                        help="yaml file for configuration")
    parser.add_argument('-e', '--embedder_path', type=str, required=True,
                        help="path of embedder model pt file")
    parser.add_argument('--checkpoint_path', type=str, default=None,
                        help="path of checkpoint pt file")
    parser.add_argument('-m', '--mixed_file', type=str, required=True,
                        help='path of mixed wav file')
    parser.add_argument('-r', '--reference_file', type=str, required=True,
                        help='path of reference wav file')
    parser.add_argument('-o', '--out_dir', type=str, required=True,
                        help='directory of output')

    args = parser.parse_args()

    hp = HParam(args.config)

    main(args, hp)
