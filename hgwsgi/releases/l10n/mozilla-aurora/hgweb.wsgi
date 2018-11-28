#!/usr/bin/env python
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

config = "/repo/hg/webroot_wsgi/releases/l10n/mozilla-aurora/hgweb.config"

from mercurial.hgweb import hgweb

import os
os.environ["HGENCODING"] = "UTF-8"

application = hgweb(config)

