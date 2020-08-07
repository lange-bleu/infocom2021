from utils.plotting import plot_spectrogram
import librosa
from utils.audio import Audio
from utils.hparams import HParam
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--base_dir', type=str, default='.',
                    help="Root directory of run.")
parser.add_argument('-c', '--config', type=str, required=True, default='config/config.yaml',
                    help="yaml file for configuration")

args = parser.parse_args()
hp = HParam(args.config)
# hp.audio.win_length = hp.audio.win_length * 3
# hp.audio.hop_length = hp.audio.hop_length * 3
myaudio = Audio(hp)

sk1_1, _ = librosa.load('utils/sp1_1.wav', 16000)
sk1_2, _ = librosa.load('utils/sp1_2.wav', 16000)
sk2_1, _ = librosa.load('utils/sp2_1.wav', 16000)
sk2_2, _ = librosa.load('utils/sp2_2.wav', 16000)

# ssk1_1, _ = myaudio.wav2spec(sk1_1)
# ssk1_1 = ssk1_1[:102, :125]
# print(ssk1_1.shape)
# plot_spectrogram(ssk1_1, 'sk1_1')
#
# ssk1_2, _ = myaudio.wav2spec(sk1_2)
# ssk1_2 = ssk1_2[:102, :125]
# plot_spectrogram(ssk1_2, 'sk1_2')
#
# ssk2_1, _ = myaudio.wav2spec(sk2_1)
# ssk2_1 = ssk2_1[:102, :125]
# plot_spectrogram(ssk2_1, 'sk2_1')
#
# ssk2_2, _ = myaudio.wav2spec(sk2_2)
# ssk2_2 = ssk2_2[:102, :125]
# plot_spectrogram(ssk2_2, 'sk2_2')

#############################################3
ssk1_1, _ = myaudio.wav2spec(sk1_1)
ssk1_1 = ssk1_1[:300, :125]
print(ssk1_1.shape)
plot_spectrogram(ssk1_1, 'sk1_1')

ssk1_2, _ = myaudio.wav2spec(sk1_2)
ssk1_2 = ssk1_2[50:350, :125]
plot_spectrogram(ssk1_2, 'sk1_2')

ssk2_1, _ = myaudio.wav2spec(sk2_1)
ssk2_1 = ssk2_1[:300, :125]
plot_spectrogram(ssk2_1, 'sk2_1')

ssk2_2, _ = myaudio.wav2spec(sk2_2)
ssk2_2 = ssk2_2[:300, :125]
plot_spectrogram(ssk2_2, 'sk2_2')


# ssk1_1 = ssk1_1.reshape(6, -1, 125)
# vec_ssk1_1 = np.mean(ssk1_1, axis=1)
# plot_spectrogram(vec_ssk1_1, 'vec_sk1_1')
#
# ssk1_2 = ssk1_2.reshape(6, -1, 125)
# vec_ssk1_2 = np.mean(ssk1_2, axis=1)
# plot_spectrogram(vec_ssk1_2, 'vec_sk1_2')
#
# ssk2_1 = ssk2_1.reshape(6, -1, 125)
# vec_ssk2_1 = np.mean(ssk2_1, axis=1)
# plot_spectrogram(vec_ssk2_1, 'vec_sk2_1')
#
# ssk2_2 = ssk2_2.reshape(6, -1, 125)
# vec_ssk2_2 = np.mean(ssk2_2, axis=1)
# plot_spectrogram(vec_ssk2_2, 'vec_sk2_2')
