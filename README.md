# Project Installation
Project developed on Ruby 2.2.3  
I recommend setting up a ruby gemset with [rvm](https://rvm.io/) before installing

Install Bundler
```shell
gem install bundler
```

Install the required gems
```shell
bundle
```

# Project Execution
## Setup Redis to capture reports
Run Redis cli
```shell
redis-cli
```
Inside Redis cli, subscripe to NEWS_XML channel
```
SUBSCRIBE NEWS_XML
```
## Execute XmlRedis project
```shell
cd lib
ruby lib/xml-redis.rb
```

# Project Configuration (Advanced)
For ease of use, configurations are hardcoded in the application.  
Following are the used defaults:
```
posts_url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
channel = "NEWS_XML"
verbose_mode = false
detailed_mode = true
```
To override this behavior following environment variables could be set.  
```
XML_REDIS_VERBOSE_MODE
XML_REDIS_POSTS_URL
XML_REDIS_CHANNEL
XML_REDIS_DETAILED_MODE
XML_REDIS_DOWNLOAD_DIR
```
example usage
```shell
XML_REDIS_VERBOSE_MODE=false XML_REDIS_DETAILED_MODE=true XML_REDIS_DOWNLOAD_DIR="downloads" XML_REDIS_POSTS_URL="http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/" XML_REDIS_CHANNEL=NEWS_XML ruby lib/xml-redis.rb
```

# Notes
[Here](https://gist.github.com/Walid-Shouman/041cc6db70e0842d1164bc7ad362c032) I collected the articles/questions/websites that I found pretty useful in developing this project.
*Detailed mode:* extracts the size and modification_date of the posts_url.
*Verbose mode:* made for debugging purposes.
Only post_loader.rb got documented so far.  
Both zipped files and reports are checked to avoid redownloading/republishing.  
The key used for the posts is their name, we also check the value in case of any modification of size or modification date.  
The key used for the reports is their name.  
