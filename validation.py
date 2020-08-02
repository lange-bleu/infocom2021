import os
import time
import logging
import argparse

from utils.train import train_hide, train_focus
from utils.hparams import HParam
from utils.writer import MyWriter
from datasets.val_dataloader_focus import create_dataloader as create_focus_dataloader
from datasets.val_dataloader_hide import create_dataloader as create_hide_dataloader
from utils.evaluation import validate_hide
from utils.evaluation import validate_focus

import os
import math
import torch
import torch.nn as nn
import traceback

from utils.adabound import AdaBound
from utils.audio import Audio
from utils.evaluation import validate_hide, validate_focus
from model.model import VoiceFilter
from model.embedder import SpeechEmbedder


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--base_dir', type=str, default='.',
                        help="Root directory of run.")
    parser.add_argument('-c', '--config', type=str, required=True, default='config/config.yaml',
                        help="yaml file for configuration")
    parser.add_argument('-e', '--embedder_path', type=str, required=True, default=' model/embedder.pt',
                        help="path of embedder model pt file")
    parser.add_argument('--checkpoint_path', type=str, default=None,
                        help="path of checkpoint pt file")
    parser.add_argument('-m', '--model', type=str, required=True,
                        help="Name of the model. Used for both logging and saving checkpoints.")
    parser.add_argument('-g', '--gpu', type=int, required=True, default='1',
                        help="ID of the selected gpu. Used for gpu selection.")
    parser.add_argument('-k', '--hide', type=int, required=True, default='1',
                        help="choose to train a hide or focus model, 1 for hide, 0 for focus")
    args = parser.parse_args()

    hp = HParam(args.config)
    with open(args.config, 'r') as f:
        # store hparams as string
        hp_str = ''.join(f.readlines())

    pt_dir = os.path.join(args.base_dir, hp.log.chkpt_dir, args.model)
    os.makedirs(pt_dir, exist_ok=True)

    log_dir = os.path.join(args.base_dir, hp.log.log_dir, args.model)
    os.makedirs(log_dir, exist_ok=True)

    chkpt_path = args.checkpoint_path if args.checkpoint_path is not None else None

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(os.path.join(log_dir,
                '%s-%d.log' % (args.model, time.time()))),
            logging.StreamHandler()
        ]
    )
    logger = logging.getLogger()

    if hp.data.train_dir == '' or hp.data.test_dir == '':
        logger.error("train_dir, test_dir cannot be empty.")
        raise Exception("Please specify directories of data in %s" % args.config)

    writer = MyWriter(hp, log_dir)

    torch.cuda.set_device(args.gpu)
    embedder_pt = torch.load(args.embedder_path)
    embedder = SpeechEmbedder(hp).cuda()
    embedder.load_state_dict(embedder_pt)
    embedder.eval()

    audio = Audio(hp)
    model = VoiceFilter(hp).cuda()
    checkpoint = torch.load(chkpt_path, map_location='cuda:0')
    model.load_state_dict(checkpoint['model'])
    step = 1
    if args.hide:
        testloader = create_hide_dataloader(hp, args, train=False)
    else:
        testloader = create_focus_dataloader(hp, args, train=False)
    while True:
        if args.hide:
            validate_hide(audio, model, embedder, testloader, writer, step)
            step = step + 1
        else:
            validate_focus(audio, model, embedder, testloader, writer, step)
            step = step + 1
        print(step)
