 # -- RapidApp "Chinook" Video Demo Series --
 #
 # Part 1. Intro and Setup
 #
 # * Agenda
 #    * Build a new webapp from scratch, using RapidApp
 #    * Database-driven, with the "RapidDbic" plugin
 #       (CRUD, query builder, custom views, etc)
 #    * Using the "Chinook" sample database
 #       (http://chinookdatabase.codeplex.com/)
 #    * All steps performed live/real-world within this shell
 #       (SSH session on an ordinary Linux box)
 #    * Test and demo as we go in Firefox
 #    * Record all commands & changes real-time in Git
 #       (https://github.com/IntelliTree/RA-ChinookDemo)
 #
 # -->
###################################################################
#   +++ COMMAND LOG/HISTORY FOR THIS SHELL (to follow along) +++
#
# github.com/IntelliTree/RA-ChinookDemo/blob/master/cmd_history.sh
#
###################################################################
 # --
 #
 # * You should already know about:
 #    *  Perl
 #    *  CPAN
 #    *  Catalyst
 #    *  DBIx::Class (aka "DBIC")
 #    *  Relational database concepts
 #    *  Git
 #    *  Linux/bash
 #
 # ----
clear
 # Install the latest RapidApp (and its dependencies):
cpanm RapidApp
 #
 # --> (Side note: if you don't have "cpanm")
 #
 #   cpan App::cpanminus # <-- install cpanminus
 #   (see also http://metacpan.org/module/App::cpanminus)
 #
 # --
 #
clear
 # Create new Catalyst app "RA::ChinookDemo":
catalyst.pl RA::ChinookDemo
cd RA-ChinookDemo/  # <-- Enter the new app directory
 #
 # Initialize git repo and setup remote (on Github)
git init 
git remote add origin   git@github.com:IntelliTree/RA-ChinookDemo.git
 #
 # Setup 'Commit' alias/shortcut:
alias Commit='\
    history -w && \
    cp $HISTFILE cmd_history.sh && \
    RestoreHistNewlines cmd_history.sh && \
    git add --all && \
    git commit -m'
 #
 # Setup 'RestoreHistNewlines' alias (used in 'Commit' above)
 # - 'sed' command puts newlines back for multi-line commands 
 #   that used backslash (\) to escape newlines. They get stripped
 #   by the shell when recorded in the history file, and this
 #   puts them back... 
 #   This is just for readability in cmd_history.sh:
alias RestoreHistNewlines='\
  sed -i -e \
   '"'"'/\\$/,/[^\\]$/{p;d;};/^[a-z]/s/ \( \) *\([^#]\)/ \\\n \1 \2/g'"'"''
 #
 # Now we can record progress & history in a simple one-liner:
Commit 'first commit - freshly created Catalyst app'
clear
 # Download the Chinook sample database:
 # (http://chinookdatabase.codeplex.com/)
mkdir sql
cp ../Chinook1.4_Sqlite/Chinook_Sqlite_AutoIncrementPKs.sql sql/
ls -lh sql/Chinook_Sqlite_AutoIncrementPKs.sql
 #
 # Create new SQLite database (takes ~ 10 minutes)
time sqlite3 chinook.db < sql/Chinook_Sqlite_AutoIncrementPKs.sql
 #
Commit 'setup chinook SQLite database'
 #
 # Create DBIC schema/model (using the Catalyst Helper)
 # -See: metacpan.org/module/Catalyst::Helper::Model::DBIC::Schema
script/ra_chinookdemo_create.pl     model DB     DBIC::Schema     RA::ChinookDemo::DB     create=static generate_pod=0     dbi:SQLite:chinook.db     sqlite_unicode=1     on_connect_call='use_foreign_keys'     quote_names=1  #<-- important!
 #
Commit 'Created DBIC schema/model "DB"'
 #
Commit '01_prepared_app'
git tag 01_prepared_app
# Push to Github (First push, with tags):
git push -u --tags origin master
clear
 # -- RapidApp "Chinook" Video Demo Series --
 #
 #  Part 2. RapidDbic Basics
 #
 # * Progress so far:
 #   * Created 'RA::ChinookDemo' with catalyst.pl
 #   * Setup SQLite database 'chinook.db'
 #      (http://chinookdatabase.codeplex.com/)
 #   * Created Catalyst model 'DB' (DBIC::Schema)
 #   * Setup git (https://github.com/IntelliTree/RA-ChinookDemo)
 #   * 'Commit' shell alias - records cmd history with changes
 #      (cmd_history.sh)
 #
 # ----
 #
git log
 #
 # Configure bare-bones RapidDbic:
vim lib/RA/ChinookDemo.pm
 #
 # Remove the auto-generated Root Controller:
 # - Needed because local app controllers always take precidence
rm -f lib/RA/ChinookDemo/Controller/Root.pm
Commit '(1) - Bare-bones working app (RapidDbic)'
 # Start the test server:
script/ra_chinookdemo_server.pl
 #
 # Configure joined columns
vim lib/RA/ChinookDemo.pm
Commit '(2) - example joined columns (grid configs)'
 # Start the test server:
script/ra_chinookdemo_server.pl
 #
 # Set 'display_column' for Sources
vim lib/RA/ChinookDemo.pm
Commit '(3) - configured display_columns (TableSpecs)'
 # Start the test server:
script/ra_chinookdemo_server.pl
 #
 # Enable grid editing
vim lib/RA/ChinookDemo.pm
Commit '(4) - turned on grid editing for all Sources'
 # Start the test server:
script/ra_chinookdemo_server.pl
 #
 # Set custom CRUD options
vim lib/RA/ChinookDemo.pm
Commit '(5) - configured various CRUD options'
 # Start the test server:
script/ra_chinookdemo_server.pl
 #
 # Set certain Sources to be dropdowns 
vim lib/RA/ChinookDemo.pm
Commit '(6) - WILL CHANGE - RESUME FROM LAST COMMIT'
