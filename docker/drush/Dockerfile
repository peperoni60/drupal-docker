# This is an excerpt from
# https://github.com/RobLoach/drush-docker/issues/32#issuecomment-222321265
#

FROM drush/drush

# Move drush to a more generic path so it can be used with any image
RUN mkdir -p /drush && \
    mv -f /usr/local/bin/drush /drush/drush

# Volume the drush path so we can use it with other containers
VOLUME /drush
VOLUME /root/.drush

# Change the entrypoint to match the new drush path
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]