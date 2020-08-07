from utils.plotting import plot_spectrogram
import librosa
from utils.audio import Audio
from utils.hparams import HParam
import argparse
from sklearn.metrics.pairwise import cosine_similarity
import glob
import os
import numpy as np
import matplotlib.pyplot as plt
import scipy

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--base_dir', type=str, default='.',
                    help="Root directory of run.")
parser.add_argument('-c', '--config', type=str, required=True, default='config/config.yaml',
                    help="yaml file for configuration")

args = parser.parse_args()
hp = HParam(args.config)

myaudio = Audio(hp)
wlen = 400
hlen = 200
hp.audio.win_length = wlen
hp.audio.hop_length = hlen

base_path = '/home/hanqing/1ASpeakerRecognition/audio_changed'
fre_rso = 8000/600
fre_range = 2e3
fre_bins = round(fre_range/fre_rso)  # 375

speaker_ids = os.listdir(base_path)
wavs = {}

for speaker_id in speaker_ids:
    wavs[speaker_id] = glob.glob(os.path.join(base_path, speaker_id, '*-norm.wav'))[:10]

speakers = len(speaker_ids)
LTAF = np.empty([speakers, 10, fre_bins])
sk_count = 0
for k,v in wavs.items():
    for idx, wav in enumerate(v):
        loaded_wav, _= librosa.load(wav, 16000)
        spect, _= myaudio.wav2spec(loaded_wav)  # (time, freq)
        spect = spect[:, :fre_bins]
        averaged = np.sum(spect, axis=0)/spect.shape[0]
        averaged = averaged.reshape(1, -1)
        LTAF[sk_count][idx] = averaged
    sk_count = sk_count + 1
print(LTAF.shape)  # (speakers, sentencePspk, chosen_freq_bins) (18, 10, 375)

LTAF = LTAF.reshape(-1, fre_bins)

# output re shape (180*180)
re = cosine_similarity(LTAF)

plt.matshow(re)
save_name = 'wlen'+str(wlen)+'hlen'+str(hlen)+'fre'+str(fre_range)+'.png'
plt.savefig(save_name)
scipy.io.savemat('matrix.mat', {'speakers':re})

