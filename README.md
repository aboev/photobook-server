## Photobook  
[![Photobook](https://developer.android.com/images/brand/en_app_rgb_wo_45.png)](https://play.google.com/store/apps/details?id=com.freecoders.photobook)

Photobook is an image sharing social service. You can express your feelings, emotions and memories; draw inspiration from public photo channels - animals, nature, travel, technology and much more.

[Client Repository](https://github.com/aboev/photobook-client)

[Server Repository](https://github.com/aboev/photobook-server)

### Developer's guide

1. Prerequisites: imagemagick, postgresql, redis
2. Register [aws web services](http://aws.amazon.com) account, activate S3 storage and get AccessKeyID/SecretAccessKey (for S3 cloud storage)
3. Register [google developer](https://console.developers.google.com/) account, activate google cloud messaging API and get GoogleApiKey
4. Register sms gateway account and get login/pw (for sms-notifications)
5. Rename config/config.yml.example -> config/config.yml and replace config values in square brackets
6. Rename config/database.yml.example -> config/database.yml and replace username/password
```
bundle install
QUEUE=* rake environment resque:work
rails server
```

### Beginner's guide

Refer to install.sh (Step-by-step for Ubuntu 14.04)
