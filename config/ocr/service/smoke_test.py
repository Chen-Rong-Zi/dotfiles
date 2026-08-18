#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""三档模型加载 + 推理冒烟测试。用法: conda run -n rapidocr python smoke_test.py [image]"""
import sys
import time
from pathlib import Path

from rapidocr import RapidOCR

BASE = Path(__file__).resolve().parent.parent
MODELS = BASE / "models"
IMG = Path(sys.argv[1]) if len(sys.argv) > 1 else BASE / "test.png"

TIERS = ["tiny", "small", "medium"]


def make_params(tier: str) -> dict:
    return {
        "Global.model_root_dir": str(MODELS),
        "Global.use_det": True,
        "Global.use_cls": True,
        "Global.use_rec": True,
        "Det.model_path": str(MODELS / f"PP-OCRv6_det_{tier}.onnx"),
        "Cls.model_path": str(MODELS / "ch_ppocr_mobile_v2.0_cls_mobile.onnx"),
        "Rec.model_path": str(MODELS / f"PP-OCRv6_rec_{tier}.onnx"),
    }


def main() -> None:
    for tier in TIERS:
        t0 = time.time()
        engine = RapidOCR(params=make_params(tier))
        load_s = time.time() - t0
        t1 = time.time()
        out = engine(str(IMG))
        infer_s = time.time() - t1
        texts = list(out.txts) if out.txts else []
        print(f"[{tier:6s}] load={load_s:.1f}s infer={infer_s:.2f}s -> {texts}")
        engine = None  # free


if __name__ == "__main__":
    main()
