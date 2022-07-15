
# RUBY_VERSION := $(shell cat .ruby-version | tr -d ' ')

# cat:
# 	docker-compose run $(PROJECT) cat /usr/local/bundle/ruby/$(RUBY_VERSION)/gems/sprockets-rails-2.3.3/lib/sprockets/rails/task.rb | vim '+set number' '+set ft=ruby' +68 -

