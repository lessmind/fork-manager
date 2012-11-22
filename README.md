Why fork-manager
----------------
How many forks do you have?

The more forks, the more same work you have to do with it.

I often doing the same thing when I'm working with a forked repository, such like
* clone my fork
* add the fork source into the git remote
* checkout updates from git remote
* apply wanted updates to mine
* ...etc

That's not a big deal when you just have one fork, but when you have a bunch of them, that's really annoying to apply similar operation to each one.

How to use it
-------------
### Clone
```sh
git clone git://github.com/lessmind/fork-manager.git <path>
```
### Configure
Under \<path\>, edit your config file as sample below, and save it into \<path\>/config
```conf
# lines start with # will be ignore, blank line will be ignores, too

# the <clone path>, this line should start with [path] as the first column,
# and [clone path] as second where you wanna put the cloned repository, after initialized,
# the repository will be put into <path>/repos/<clone path>
path repositoryA
# some remote repository defines, these should start with [remote] as the first column,
# the [remote name] as second and it's [path] as third.
# remote origin, which you probably have write access
remote origin git@xxxxxx/
# the fork source
remote source git://xxxxxx/
# maybe some another fork
remote other git://xxxxxx/

# and some more repository settings
path repositoryB
remote origin git@xxxxxx/
remote source git://xxxxxx/
remote other git://xxxxxx/
```

### __NOTICE__ All execution below will force overwrite your current master branch to origin/master, if your remote origin changed or added in the config file, so if you have some local change not pushed yet, you may want to backup your master branch before executing them.

### Initialize
Instruction below will create all repositories in your config file and put it under **\<path\>/repos**, fetch all remotes, and set your master branch track to origin/master
```sh
cd <path>
./do init
```
### Fetch all remote repositories
```sh
cd <path>
./do fetch
```
### Execute command to each repository. (This will init the repositories automaticly if it's not initialized)
```sh
cd <path>
./do git log -5 # show all recent 5 commits
./do git status # show all git status
./do ls
./do touch README.md
```
