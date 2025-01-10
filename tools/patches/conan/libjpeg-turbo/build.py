#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bincrafters import build_template_default
import platform
import copy

if __name__ == "__main__":

    builder = build_template_default.get_builder()

    items = []
    for item in builder.items:
        if item.options["libjpeg-turbo:shared"] == False:
            items.append(item)
    builder.items = items

    builder.run()