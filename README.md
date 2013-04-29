# SassMeister #

Become a Sass master with SassMeister, the Sass playground.


## Installation ##

```
git clone https://github.com/jedfoster/SassMeister.git
cd SassMeister
bundle install
```

Certain features of the app depend on the GitHub API. In production the app's GitHub credentials are stored in environment variables, but in development I use a YAML file to store those. You'll need to [register your app with GitHub](https://github.com/settings/applications/new). Once you have your client ID and secret, rename `github.example.yml` to `github.yml` and paste in your app's credentials. Mine looks something like this:

```yaml
client_id: 9ef1xxxx
client_secret: 5784xxxxxxxx
```

**FAIR WARNING:** Your client ID and secret should _not_ be shared publicly. Do not commit github.yml to your repo, especially if you post your repo on GitHub. Read the instructions for configuring Heroku with your credentials, below.

Once you have your `github.yml` file:

```
rake server
# Rock and Roll
```

Go to [127.0.0.1:3000](http://127.0.0.1:3000) and start playing with Sass!


### GitHub authentication on Heroku ###

Since the YAML file with your API credentials is not committed to your repo, it won't be sent to Heroku, so we need another way of storing that information. Enter Heroku environment variables:

```
heroku config:set GITHUB_ID=9ef1xxxx
heroku config:set GITHUB_SECRET=5784xxxxxxxx
heroku open
# Rock and Roll, again.
```


## Tests ##

Test code for each of the included Sass libraries can be found [here](https://github.com/jedfoster/SassMeister/blob/master/TESTS.md).

## Caveats ##

@imports will probably not work the way you'd expect. Spriting with Compass will definitely not work.

If you find anything else that doesn't work, please let me know.

## Author
SassMeister is written by [Jed Foster][jedfoster].

The name was inspired by a [Seattle Sass Meetup][meetup] presentation from [PeepCode Screencasts][peepcode].

## License
Copyright (c) 2012-2013 Jed Foster<br>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[jedfoster]: http://jedfoster.com
[meetup]: http://www.meetup.com/SASSlang/
[peepcode]: [https://peepcode.com]
