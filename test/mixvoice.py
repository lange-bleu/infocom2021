import librosa
import numpy as np


def mixtwo(file1, file2, outpath):
    sr = librosa.get_samplerate(file1)
    w1, _ = librosa.load(file1, sr)
    w2, _ = librosa.load(file2, sr)
    audio_len = 4
    L = int(sr * audio_len)
    if w1.shape[0] < L or w2.shape[0] < L:
        return
    w1, w2 = w1[:L], w2[:L]

    mixed = w1 + w2

    norm = np.max(np.abs(mixed)) * 1.1
    w1, w2, mixed = w1 / norm, w2 / norm, mixed / norm
    librosa.output.write_wav(outpath, mixed, sr)


def mixthree(file1, file2, file3, outpath):
    sr = librosa.get_samplerate(file1)
    w1, _ = librosa.load(file1, sr)
    w2, _ = librosa.load(file2, sr)
    w3, _ = librosa.load(file3, sr)
    audio_len = 4
    L = int(sr * audio_len)
    if w1.shape[0] < L or w2.shape[0] < L or w3.shape[0] < L:
        return
    w1, w2, w3 = w1[:L], w2[:L], w3[:L]

    mixed = w1 + w2 + w3

    norm = np.max(np.abs(mixed)) * 1.1
    mixed = mixed / norm
    librosa.output.write_wav(outpath, mixed, sr)


if __name__ == '__main__':
    file1 = 'test_data/ref8.wav'
    file2 = 'test_data/3b.wav'
    file3 = '/home/hanqing/1ASpeakerRecognition/16kHzUltradata/5/bad/9.wav'
    outpath = 'test_data/ref83.wav'
    mixtwo(file1, file2, outpath)
    # mixthree(file1, file2, file3, outpath)