# A workaround for a warning that spams the logs whenever we do ES searchs. More on the topic here:
# https://github.com/elastic/elasticsearch-rails/issues/666
# After we update the elasticsearch-rails gem to a version > 0.1.9 and Hashie to a version >= 3.5.3,
# then we should remove this file and assert that the spammy log is gone.

Hashie.logger = Logger.new('/dev/null')
