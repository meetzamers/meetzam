last update: Feb.27 2017

# Git Reference Doc

### Branching Workflow

###### 1. Making a new local branch
If you want to make a local branch and working on new feature for your project. First navigate to your local repository and type
`git checkout master` to switch to your master branch if you are not already on the master branch. Then type `git pull` to make sure your local master is the latest version.

Now your local master is the latest version, you can make a new local branch by typing `git checkout -b <your-branch-name>`, `checkout -b` will create a new branch of name `<your-branch-name>` and automatically switch to the new branch that you just created.

###### 2. Push your new local branch onto your remote repository
After done creating the branch on your local repository, you now need to push this new branch onto your project's remote repository.

You can do that by typing `git push --set-upstream origin <your-branch-name>`.

This command will upload your local branch of name `<your-branch-name>` to your project's remote repository of name `origin`, and create a remote branch of name `<your-branch-name>`, which later referenced by the name `origin/<your-branch-name>`.

This command will then link your local branch named `<your-branch-name>` with the remote branch named `origin/<your-branch-name>` together. By link them together, when you type the command `git push` at your local branch `<your-branch-name>`, your changes will be uploaded to the remote branch `origin/<your-branch-name>`.

###### 3. Making changes to your local branch.
Now that you have setup the new branch both locally as well as remotely. You can working on your new feature on the local branch now.

When ever you have made some progress with your new feature, such as fixed a bug, or finished writing a piece of working code, you should commit this change to you local repository's **STAGE**.

**STAGE** is an area where your commits will go. It is the place between your local workspace and the remote repository, where you *decorate* your new feature by using `git commit`, `git add`, and `git rm`.

If your change involved new files that you created, you need to on **STAGE** these new files. You can do that by typing `git add <file_1> <file_2> ... <file_n>`. Or you can type `git commit --all` to on **STAGE** all new files.

###### 4. Push your changes to remote branch.


When you finished developing your feature, you have a nicely decorated piece of feature on **STAGE**. And then you can deliver that feature to your remote branch by using `git push` from your local branch.

###### 5. Pull request and celebrate.

You have finished developing your new feature, well done! Go to your remote repository on Github and open a pull request, invite your team members review your code and if everything works fine, someone will merge it for you!

**And celebrate for you hard work!**
