# latest does not exist, as of 2016-06-02, so use 1.0
FROM drupalconsole/console:1.0


# Move drupal console to a more generic path so it can be used with any image
RUN ln -s /composer /drupal

# Volume the drupal path so we can use it with other containers
VOLUME /drupal
VOLUME /root/.console

# Change the entrypoint to match the new drupal path and include UMASK value
COPY ./docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]