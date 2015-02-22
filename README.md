Dashboard and Report Scripts
============================

In order to use the Github script(s) you'll need to go to your "Settings", denoted by the gear
icon in the upper righthand corner of Github.com. Once on your settings page you'll want to go
to "Applications" which is currently the third from last option on the "Personal settings"
menu.

Configure a personal access token.

You're going to want to copy this access token into the github.yml configuration file along
with your github username.

Once you have done this, you should be able to run:

```
ruby github.rb
```

That will give you a breakdown of the organizations that you're a member of and all of the
issues.
