# Git Command Cheat Sheet

## Setup and Configuration
| Command | Description |
|---------|-------------|
| `git config --global user.name "[name]"` | Set the name you want attached to your commit transactions |
| `git config --global user.email "[email address]"` | Set the email you want attached to your commit transactions |
| `git config --global color.ui auto` | Enable helpful colorization of command line output |

## Creating Repositories
| Command | Description |
|---------|-------------|
| `git init` | Initialize a local Git repository |
| `git clone [url]` | Create a local copy of a remote repository |

## Basic Snapshotting
| Command | Description |
|---------|-------------|
| `git status` | Check status |
| `git add [file-name.txt]` | Add a file to the staging area |
| `git add -A` | Add all new and changed files to the staging area |
| `git commit -m "[commit message]"` | Commit changes |
| `git rm -r [file-name.txt]` | Remove a file (or folder) |

## Branching & Merging
| Command | Description |
|---------|-------------|
| `git branch` | List branches (the asterisk denotes the current branch) |
| `git branch -a` | List all branches (local and remote) |
| `git branch [branch name]` | Create a new branch |
| `git branch -d [branch name]` | Delete a branch |
| `git push origin --delete [branch name]` | Delete a remote branch |
| `git checkout -b [branch name]` | Create a new branch and switch to it |
| `git checkout -b [branch name] origin/[branch name]` | Clone a remote branch and switch to it |
| `git checkout [branch name]` | Switch to a branch |
| `git checkout -` | Switch to the branch last checked out |
| `git checkout -- [file-name.txt]` | Discard changes to a file |
| `git merge [branch name]` | Merge a branch into the active branch |
| `git merge [source branch] [target branch]` | Merge a branch into a target branch |
| `git stash` | Stash changes in a dirty working directory |
| `git stash clear` | Remove all stashed entries |

## Sharing & Updating Projects
| Command | Description |
|---------|-------------|
| `git push origin [branch name]` | Push a branch to your remote repository |
| `git push -u origin [branch name]` | Push changes to remote repository (and remember the branch) |
| `git push` | Push changes to remote repository (remembered branch) |
| `git push origin --delete [branch name]` | Delete a remote branch |
| `git pull` | Update local repository to the newest commit |
| `git pull origin [branch name]` | Pull changes from remote repository |
| `git remote add origin ssh://git@github.com/[username]/[repository-name].git` | Add a remote repository |
| `git remote set-url origin ssh://git@github.com/[username]/[repository-name].git` | Set a repository's origin branch to SSH |

## Inspection & Comparison
| Command | Description |
|---------|-------------|
| `git log` | View changes |
| `git log --summary` | View changes (detailed) |
| `git log --oneline` | View changes (briefly) |
| `git diff [source branch] [target branch]` | Preview changes before merging |

## Advanced Commands
| Command | Description |
|---------|-------------|
| `git rebase [branch]` | Rebase your current HEAD onto [branch] |
| `git reset --hard [commit]` | Discard all history and changes back to the specified commit |
| `git grep "[search term]"` | Search the working directory for [search term] |
| `git blame [file]` | Show who changed what and when in [file] |
| `git tag [tag name] [commit SHA]` | Create a tag for a commit |
| `git fetch` | Fetch changes from the remote, but don't merge into HEAD |
| `git cherry-pick [commit SHA]` | Apply the changes introduced by some existing commits |

## Deleting and Reverting
| Command | Description |
|---------|-------------|
| `git clean -n` | Show which files would be removed from working directory |
| `git clean -f` | Remove untracked files from the working directory |
| `git clean -fd` | Remove untracked files and directories from the working directory |
| `git reset --soft HEAD~1` | Undo the last commit, but leave the changes in the staging area |
| `git reset --hard HEAD~1` | Undo the last commit and all changes |
| `git reset --hard origin/[branch name]` | Reset local branch to match the remote branch exactly |
| `git revert [commit SHA]` | Create a new commit that undoes all of the changes made in [commit SHA], then apply it to the current branch |
| `git restore [file]` | Restore a file to its state in the last commit |
| `git restore --staged [file]` | Unstage a file while retaining the changes in working directory |