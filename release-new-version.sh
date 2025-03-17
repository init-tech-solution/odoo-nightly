#!/bin/bash

export ODOO_VERSION="18.0"
export ODOO_DATE=$(date '+%Y%m%d')
export ODOO_DATE="20250317"
export ODOO_IMGTAG="v$ODOO_VERSION.$ODOO_DATE"
curl https://nightly.odoo.com/$ODOO_VERSION/nightly/tgz/odoo_$ODOO_VERSION.$ODOO_DATE.tar.gz --output odoo_$ODOO_VERSION.$ODOO_DATE.tar.gz

tar -xvzf odoo_$ODOO_VERSION.*.tar.gz
rsync -a --delete odoo-$ODOO_VERSION.post*/* ./

rm -f odoo_$ODOO_VERSION.*.tar.gz
rm -rf odoo-$ODOO_VERSION.post*

# gh auth status
# gh auth setup-git

# git config --global user.email "danh.tt1294@gmail.com"
# git config --global user.name "danhtran94"

# git remote -v

git add -A
git commit -m "chore(core): update odoo source nightly v$ODOO_VERSION.$ODOO_DATE" ||:

# git push repository_url $BUDDY_EXECUTION_BRANCH ||:
git push ||:

git tag "v$ODOO_VERSION.$ODOO_DATE" ||:
# git push -f repository_url "v$ODOO_VERSION.$ODOO_DATE"
git push -f origin "v$ODOO_VERSION.$ODOO_DATE"

export PR_URL_OLD=$PR_URL
export PR_URL=$(gh pr create --no-maintainer-edit --repo github.com/init-tech-solution/odoo-nightly --base $ODOO_VERSION --head "$ODOO_VERSION-src" --title "Update source odoo v$ODOO_VERSION.$ODOO_DATE" --body "Update source odoo v$ODOO_VERSION.$ODOO_DATE")
gh pr merge ${PR_URL:-$PR_URL_OLD} --repo github.com/init-tech-solution/odoo-nightly --merge

# docker build -f Dockerfile --platform linux/amd64 -t ghcr.io/init-tech-solution/odoo-nightly:$ODOO_IMGTAG .
docker build -f Dockerfile -t ghcr.io/init-tech-solution/odoo-nightly:$ODOO_IMGTAG .
docker push ghcr.io/init-tech-solution/odoo-nightly:$ODOO_IMGTAG