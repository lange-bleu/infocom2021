import os
import glob
import torch
import librosa
import argparse

from utils.audio import Audio
from utils.hparams import HParam
from model.model import VoiceFilter
from model.embedder import SpeechEmbedder
import warnings
warnings.filterwarnings("ignore")

def search(words):
    """Return list of words containing 'son'"""
    newlist = [w for w in words if 'son' in w]
    return newlist

def main(args):
    args = {
        "config": 'config/config.yaml',
        "embedder_path": 'model/embedder.pt',
        "checkpoint_path": 'enhance_my_voice/chkpt_201000.pt',
        "mixed_file": 'utils/speakerA.wav',
        "reference_file": 'utils/speakerA.wav',
        "out_dir": 'output',
    }

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
if __name__ == '__main__':

    # parser = argparse.ArgumentParser()
    # parser.add_argument('-c', '--config', type=str, default='config/config-medium.yaml',
    #                     help="yaml file for configuration")
    # parser.add_argument('-e', '--embedder_path', type=str, default='model/embedder.pt',
    #                     help="path of embedder model pt file")
    # parser.add_argument('--checkpoint_path', type=str, default=None,
    #                     help="path of checkpoint pt file")
    # parser.add_argument('-m', '--mixed_file', type=str, default='v3.2.3-oldDataset',
    #                     help='path of mixed wav file')
    # parser.add_argument('-r', '--reference_file', type=str, default='utils/speakerA.wav',
    #                     help='path of reference wav file')
    # parser.add_argument('-o', '--out_dir', type=str, default='output',
    #                     help='directory of output')

    args = {
  "config": 'config/config.yaml',
  "embedder_path": 'model/embedder.pt',
  "checkpoint_path": 'enhance_my_voice/chkpt_201000.pt',
  "mixed_file": 'utils/speakerA.wav',
  "reference_file": 'utils/speakerA.wav',
  "out_dir": 'output',
}
    ans=main(args)
    print(ans.shape,ans)