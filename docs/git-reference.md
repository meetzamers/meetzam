# Git Reference Doc

### Branching Workflow

###### 1. Making a new local branch
If you want to make a local branch and working on new feature for your project. First navigate to your local repository and type
`git checkout master` to switch to your master branch if you are not already on the master branch. Then type `git pull` to make sure your local master is the latest version.

Now your local master is the latest version, you can make a new local branch by typing `git checkout -b <your-branch-name>`, `checkout -b` will create a new branch of name `<your-branch-name>` and automatically switch to the new branch that you just created.

###### 2. Push your new local branch onto your remote repository
You only created the branch on your local repository, and you now need to push this new branch onto your project's remote repository, you can do that by typing `git push --set-upstream origin <your-branch-name>`. This command will upload your local branch of name `<your-branch-name>` to your project's remote repository of name `origin`, and create a remote branch of name `<your-branch-name>`, which later will be referenced by the name `origin/<your-branch-name>`.

Then this command will link your local branch of name `<your-branch-name>` with the remote branch of name `origin/<your-branch-name>`. By link them together, when you type the command `git push` at your local branch of name `<your-branch-name>`, your changes will be uploaded to the remote branch `origin/<your-branch-name>`.

###### 3. Making changes to your local branch.
Now that you have setup the new branch both locally as well as remotely. You can working on your new feature on the local branch now.

When ever you have made some progress with your new feature, such as fixed a bug, or finished writing a piece of working code, you should commit this change to you local repository's stage.

If your change involved new files that you created, you need to on stage these new files. You can do that by typing `git add <file_1> <file_2> ... <file_n>`. Or you can type `git commit --all` to on stage all new files.
