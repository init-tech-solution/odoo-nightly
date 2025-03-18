#!/bin/bash
export PROJECT_NAME="project-odoo"

mkdir -p projects/$PROJECT_NAME/data

# This script creates symbolic links for Odoo projects extra-addons
ln -s $HOME/code/odoo/$PROJECT_NAME/extra-addons projects/$PROJECT_NAME

ln -s odoo $HOME/code/odoo/$PROJECT_NAME

# Copy the Odoo configuration template to the project directory
cp etc/odoo.conf.tmpl projects/$PROJECT_NAME/odoo.conf

# Start the Odoo server with the specified configuration file
./odoo-bin -c projects/$PROJECT_NAME/odoo.conf