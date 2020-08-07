from utils.plotting import plot_spectrogram
import librosa
from utils.audio import Audio
from utils.hparams import HParam
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--base_dir', type=str, default='.',
                    help="Root directory of run.")
parser.add_argument('-c', '--config', type=str, required=True, default='config/config.yaml',
                    help="yaml file for configuration")

args = parser.parse_args()
hp = HParam(args.config)

myaudio = Audio(hp)
sk1_1, _ = librosa.load('utils/sp1_1.wav', 16000)
sk1_2, _ = librosa.load('utils/sp1_2.wav', 16000)
sk2_3, _ = librosa.load('utils/sp2_3.wav', 16000)
sk1_3, _ = librosa.load('utils/sp1_3.wav', 16000)

ssk1_1, _ = myaudio.wav2spec(sk1_1)
ssk1_1 = ssk1_1[:, :125]
plot_spectrogram(ssk1_1, 'sk1_1')

ssk1_2, _ = myaudio.wav2spec(sk1_2)
ssk1_2 = ssk1_2[:, :125]
plot_spectrogram(ssk1_2, 'sk1_2')

ssk2_1, _ = myaudio.wav2spec(sk2_3)
ssk2_1 = ssk2_1[:, :125]
plot_spectrogram(ssk2_1, 'sk2_1')

ssk1_3, _ = myaudio.wav2spec(sk1_3)
ssk1_3 = ssk1_3[:, :125]
plot_spectrogram(ssk1_3, 'sk1_3')