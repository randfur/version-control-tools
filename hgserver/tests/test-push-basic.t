#require hgmodocker

  $ . $TESTDIR/hgserver/tests/helpers.sh
  $ hgmoenv

Create repository and user

  $ hgmo create-repo mozilla-central scm_level_3
  (recorded repository creation in replication log)
  $ hgmo create-ldap-user user1@example.com user1 1500 'User 1' --scm-level 3 --key-file user1
  $ cat >> $HGRCPATH << EOF
  > [ui]
  > ssh = ssh -F `pwd`/ssh_config -i `pwd`/user1 -l user1@example.com
  > EOF

Needed so hgweb_dir refreshes.
TODO we should fix this in hgweb_dir or a hack of hgweb_dir, support for
this is in Mercurial 3.6
  $ sleep 1

Set up local clone

  $ hg clone ${HGWEB_0_URL}mozilla-central
  destination directory: mozilla-central
  no changes found
  updating to branch default
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved

  $ cd mozilla-central
  $ touch foo
  $ hg -q commit -A -m initial

Pushing via http:// says pushing isn't allowed

  $ hg push ${HGWEB_0_URL}mozilla-central
  pushing to http://$DOCKER_HOSTNAME:*/mozilla-central (glob)
  searching for changes
  abort: authorization failed
  [255]

Pushing via ssh:// works

  $ hg push ssh://${SSH_SERVER}:${SSH_PORT}/mozilla-central
  pushing to ssh://$DOCKER_HOSTNAME:$HGPORT/mozilla-central
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files
  remote: recorded push in pushlog
  remote: 
  remote: View your change here:
  remote:   https://hg.mozilla.org/mozilla-central/rev/77538e1ce4bec5f7aac58a7ceca2da0e38e90a72
  remote: recorded changegroup in replication log in \d+\.\d+s (re)

Blackbox logging recorded appropriate entries

  $ hgmo exec hgssh cat /repo/hg/mozilla/mozilla-central/.hg/blackbox.log
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for blackbox took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for clonebundles (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for mozhooks (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for mozhooks took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for obsolescencehacks (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for obsolescencehacks took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for pushlog (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for pushlog took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for replicateowner (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for serverlog (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for readonly (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for readonly took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for vcsreplicator (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for vcsreplicator took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for cinnabarclone (glob)
  * root @0000000000000000000000000000000000000000 (*)> > all reposetup took * (glob)
  * root @0000000000000000000000000000000000000000 (*)> loading additional extensions (glob)
  * root @0000000000000000000000000000000000000000 (*)> - processing 10 entries (glob)
  * root @0000000000000000000000000000000000000000 (*)> > loaded 0 extensions, total time * (glob)
  * root @0000000000000000000000000000000000000000 (*)> - loading configtable attributes (glob)
  * root @0000000000000000000000000000000000000000 (*)> - executing uisetup hooks (glob)
  * root @0000000000000000000000000000000000000000 (*)> > all uisetup took * (glob)
  * root @0000000000000000000000000000000000000000 (*)> - executing extsetup hooks (glob)
  * root @0000000000000000000000000000000000000000 (*)> > all extsetup took * (glob)
  * root @0000000000000000000000000000000000000000 (*)> - executing remaining aftercallbacks (glob)
  * root @0000000000000000000000000000000000000000 (*)> > remaining aftercallbacks completed in * (glob)
  * root @0000000000000000000000000000000000000000 (*)> - loading extension registration objects (glob)
  * root @0000000000000000000000000000000000000000 (*)> > extension registration object loading took * (glob)
  * root @0000000000000000000000000000000000000000 (*)> extension loading complete (glob)
  * root @0000000000000000000000000000000000000000 (*)> - executing reposetup hooks (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for blackbox (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for blackbox took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for clonebundles (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for mozhooks (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for mozhooks took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for obsolescencehacks (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for obsolescencehacks took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for pushlog (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for pushlog took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for replicateowner (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for serverlog (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for readonly (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for readonly took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for vcsreplicator (glob)
  * root @0000000000000000000000000000000000000000 (*)>   > reposetup for vcsreplicator took * (glob)
  * root @0000000000000000000000000000000000000000 (*)>   - running reposetup for cinnabarclone (glob)
  * root @0000000000000000000000000000000000000000 (*)> > all reposetup took * (glob)
  * root @0000000000000000000000000000000000000000 (*)> init /repo/hg/mozilla/mozilla-central exited 0 after * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for blackbox took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for clonebundles (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for mozhooks (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for mozhooks took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for obsolescencehacks (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for obsolescencehacks took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for pushlog (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for pushlog took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for replicateowner (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for serverlog (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for readonly (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for readonly took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for vcsreplicator (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   > reposetup for vcsreplicator took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)>   - running reposetup for cinnabarclone (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> > all reposetup took * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> -R /repo/hg/mozilla/mozilla-central serve --stdio (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *: BEGIN_SSH_SESSION mozilla-central user1@example.com (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND hello (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND between (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *: BEGIN_SSH_COMMAND protocaps (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND batch (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND listkeys (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND listkeys (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND unbundle (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnopen: hgext_vcsreplicator.pretxnopenhook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-prechangegroup: hgext_readonly.prechangegrouphook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> mozhooks.pretxnchangegroup.prevent_subrepos took * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> mozhooks.pretxnchangegroup.prevent_symlinks took * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> mozhooks.pretxnchangegroup.single_root took * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnchangegroup: hgext_mozhooks.pretxnchangegroup finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnchangegroup: hgext_pushlog.pretxnchangegrouphook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnchangegroup: hgext_vcsreplicator.pretxnchangegrouphook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> writing .hg/cache/tags2-served with 0 tags (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> writing .hg/cache/tags2 with 0 tags (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnclose: mozhghooks.populate_caches.hook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-pretxnclose: hgext_vcsreplicator.pretxnclosehook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> updated base branch cache in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> wrote base branch cache with 1 labels and 1 nodes (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-txnclose: hgext_vcsreplicator.txnclosehook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> exthook-changegroup.a_recordlogs: /var/hg/version-control-tools/scripts/record-pushes.sh finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-changegroup: mozhghooks.push_printurls.hook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> mozhooks.changegroup.advertise_upgrade took * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-changegroup: hgext_mozhooks.changegroup finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> pythonhook-changegroup: hgext_vcsreplicator.changegrouphook finished in * seconds (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> 1 incoming changes - new heads: 77538e1ce4be (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* BEGIN_SSH_COMMAND listkeys (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *:* END_SSH_COMMAND * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> *: END_SSH_SESSION * * (glob)
  * user1@example.com @0000000000000000000000000000000000000000 (*)> -R /repo/hg/mozilla/mozilla-central serve --stdio exited 0 after * seconds (glob)

It got replicated to mirrors

  $ hgmo exec hgweb0 /var/hg/venv_replication/bin/vcsreplicator-consumer --wait-for-no-lag /etc/mercurial/vcsreplicator.ini
  $ http --no-headers ${HGWEB_0_URL}mozilla-central/json-rev/77538e1ce4be
  200
  
  {
  "node": "77538e1ce4bec5f7aac58a7ceca2da0e38e90a72",
  "date": [0.0, 0],
  "desc": "initial",
  "backedoutby": "",
  "branch": "default",
  "bookmarks": [],
  "tags": ["tip"],
  "user": "Test User \u003csomeone@example.com\u003e",
  "parents": [],
  "phase": "public",
  "pushid": 1,
  "pushdate": [*, 0], (glob)
  "pushuser": "user1@example.com",
  "landingsystem": null
  }

  $ hgmo exec hgweb1 /var/hg/venv_replication/bin/vcsreplicator-consumer --wait-for-no-lag /etc/mercurial/vcsreplicator.ini
  $ http --no-headers ${HGWEB_1_URL}mozilla-central/json-rev/77538e1ce4be
  200
  
  {
  "node": "77538e1ce4bec5f7aac58a7ceca2da0e38e90a72",
  "date": [0.0, 0],
  "desc": "initial",
  "backedoutby": "",
  "branch": "default",
  "bookmarks": [],
  "tags": ["tip"],
  "user": "Test User \u003csomeone@example.com\u003e",
  "parents": [],
  "phase": "public",
  "pushid": 1,
  "pushdate": [*, 0], (glob)
  "pushuser": "user1@example.com",
  "landingsystem": null
  }

Pushlog should be replicated

  $ http --no-headers ${HGWEB_0_URL}mozilla-central/json-pushes
  200
  
  {"1": {"changesets": ["77538e1ce4bec5f7aac58a7ceca2da0e38e90a72"], "date": *, "user": "user1@example.com"}} (glob)

Upgrade notice is advertised to clients not running bundle2

  $ echo upgrade > foo
  $ hg commit -m 'upgrade notice'
  $ hg --config devel.legacy.exchange=bundle1 push ssh://${SSH_SERVER}:${SSH_PORT}/mozilla-central
  pushing to ssh://$DOCKER_HOSTNAME:$HGPORT/mozilla-central
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files
  remote: recorded push in pushlog
  remote: 
  remote: View your change here:
  remote:   https://hg.mozilla.org/mozilla-central/rev/425a9d45c43d833916e3c803300ba4488374ac0e
  remote: 
  remote: *************************************** WARNING ****************************************
  remote: YOU ARE PUSHING WITH AN OUT OF DATE MERCURIAL CLIENT!
  remote: 
  remote: Newer versions are faster and have numerous bug fixes.
  remote: Upgrade instructions are at the following URL:
  remote: https://mozilla-version-control-tools.readthedocs.io/en/latest/hgmozilla/installing.html
  remote: ****************************************************************************************
  remote: 
  remote: recorded changegroup in replication log in \d+\.\d+s (re)

Cleanup

  $ hgmo clean
