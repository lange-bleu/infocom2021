import numpy as np
from tensorboardX import SummaryWriter

from .plotting import plot_spectrogram_to_numpy


class MyWriter(SummaryWriter):
    def __init__(self, hp, logdir):
        super(MyWriter, self).__init__(logdir)
        self.hp = hp

    def log_training(self, train_loss, step):
        self.add_scalar('train_loss', train_loss, step)

    def log_evaluation(self, test_loss, sdr,
                       mixed_wav, target_wav, purified_wav, denoised_wav,
                       mixed_spec, target_spec, purified_spec, purified_mask, denoised_spec,
                       step):
        
        self.add_scalar('test_loss', test_loss, step)
        self.add_scalar('SDR', sdr, step)

        self.add_audio('mixed_wav', mixed_wav, step, self.hp.audio.sample_rate)
        self.add_audio('target_wav', target_wav, step, self.hp.audio.sample_rate)
        self.add_audio('purified_wav', purified_wav, step, self.hp.audio.sample_rate)
        self.add_audio('denoised_wav', denoised_wav, step, self.hp.audio.sample_rate)

        self.add_image('data/mixed_spectrogram',
            plot_spectrogram_to_numpy(mixed_spec), step, dataformats='HWC')
        self.add_image('data/target_spectrogram',
            plot_spectrogram_to_numpy(target_spec), step, dataformats='HWC')
        self.add_image('result/purified_spectrogram',
            plot_spectrogram_to_numpy(purified_spec), step, dataformats='HWC')
        self.add_image('result/purified_mask',
            plot_spectrogram_to_numpy(purified_mask), step, dataformats='HWC')
        self.add_image('result/denoised_spectrogram',
            plot_spectrogram_to_numpy(denoised_spec), step, dataformats='HWC')
        self.add_image('result/estimation_error_sq',
            plot_spectrogram_to_numpy(np.square(denoised_spec - target_spec)), step, dataformats='HWC')
