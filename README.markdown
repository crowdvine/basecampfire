Simple syndication of new Basecamp messages relayed to a Campfire chatroom

# Setup

1. Copy config.example.yml to config.yml and edit
2. `ruby basecampfire.rb`
3. If it works, put it in your cron
    0,5,10,15,20,25,30,35,40,45,50,55 * * * * (ruby /your_path_here/basecampfire.rb)

# About

This is forked from http://github.com/scoop/basecampfire, with additions made by Jay Laney and Tony Stubblebine in order to:
- get it to work with 37signals new API token authentication.
- default to messages from all projects
- include the project name in the post to Campfire

Contact: tony+basecampfire@tonystubblebine.com
