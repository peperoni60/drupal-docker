# Build an image of node.js to be used in drupal zen theme development
FROM node:6-slim

# install gulp globally
RUN npm install -g gulp-cli

# Change the entrypoint to include UMASK value
COPY ./docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]