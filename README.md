commit-comment-tools
====================

## Name

commit-comment-tools

## Description

Commit-comment-tools is the tools for
[commit-comment-service](http://www.clear-code.com/services/commit-comment.html).

## Install

````
$ gem install commit-comment-tools
````

You can also use bunlder.

Gemfile:
````
source: "https://rubygems.org"
gem: "commit-comment-tools"
````

See also [clear-code/daily-report-sample](https://github.com/clear-code/daily-report-sample)

## HowTo

This tool has many options, so you can use Rake.

1. Create daily-report repository
  * See [clear-code/daily-report-sample](https://github.com/clear-code/daily-report-sample).
2. Write and commit daily reports
3. Develop your project
4. Load commits from your repositories
5. Analyze your repositories
6. Analyze your daily reports

## Usage

````
$ cct --help
Usage: cct [global options] <subcommand> [options] [args]

Subcommands:
    load-commits     Load commit information into database.
    analyze-commits  Analyze commit information in database.
    analyze-reports  Analyze daily reports.
    fetch-mails      Fetch commit mails.
    count-mails      Count commit mails.

Global Opions:
        --help                       Prints this message and quit.
````

### load-commits

Load commit information into database.

````
$ cct load-commits --help
Usage: ./bin/cct [options]
  e.g: ./bin/cct -d ./commits.db -r ./sample_project -b master
       ./bin/cct -d ./commits.db -r ./sample_project -b /pattern/

Options:
    -r, --repository=PATH            Git repository path.
    -B, --base-branch=NAME           Base branch name.
    -b, --branch=NAME                Load commits in matching branch NAME (patterns may be used).
    -d, --database=PATH              Database path.
    -h, --help                       Print this message and quit.
````

### analyze-commits

Analyze commit information in database.

````
$ cct analyze-commits --help
Usage: ./bin/cct [options]
  e.g: ./bin/cct -d ./commits.db

Options:
    -d, --database=PATH              Database path.
    -M, --max=MAX_LINES              Max lines of diff. [300]
    -s, --step=STEP                  Step. [50]
    -t, --terms=TERM1,TERM2,TERM3,   Analyze commits in these terms.
    -f, --format=FORMAT              Output format
                                     available formats: [csv, png]
                                     [csv]
    -m, --mode=MODE                  Output mode
                                     available modes: [pareto, average]
                                     [pareto]
    -o, --output-filename=PATH       Output filename.
    -a, --all                        Include all commits.
                                     This option is effective in pareto mode only.
    -h, --help                       Print this message and quit.
````

### analyze-reports

Analyze daily reports.

````
$ cct analyze-reports --help
Usage: ./bin/cct REPORT_DIRECTORY
 e.g.: ./bin/cct daily-report

Options:
    -f, --format=FORMAT              Output format
                                     available formats: [csv, png, summary]
                                     [csv]
    -o, --output-filename=PATH       Store CSV data to PATH.
    -mMEMBER1,MEMBER2,...,           Members
        --members
    -t, --terms=TERM1,TERM2,TERM3,   Analyze commits in these terms.
    -i, --mail-info=PATH             Commit mail information.
    -h, --help                       Print this message and quit.
````

### fetch-mails

Fetch commit mails.

````
$ cct fetch-mails --help
Usage: ./bin/cct [options]
  e.g: ./bin/cct -s imap.example.com -p 143 -u username -p password --no-ssl \
             -t 2013-02-01:2013-02-28,2013-03-01:2013-03-31 \
             -m commit -d /tmp/mails

Options:
    -M, --mode=MODE                  Fetch mails via MODE
                                     available modes imap, pop
                                     [imap]
    -s, --server=ADDRESS             IMAP server address.
    -P, --port=PORT                  Port number. [143]
    -u, --username=USERNAME          User name for IMAP login.
    -p, --password=PASSWORD          Password for IMAP login.
        --[no-]ssl                   Use SSL [false]
    -m, --mailbox=MAILBOX            IMAP mailbox name. [INBOX]
    -t, --terms=TERM1,TERM2,TERM3,   Analyze commits in these terms.
    -o, --output-directory=DIR       Store mails in DIR
    -h, --help                       Print this message and quit.
```

### count-mails

Count commit mails.

````
$ cct count-mails --help
Usage: ./bin/cct count-mails [options]
  e.g: ./bin/cct count-mails -d ./mails -o ./reports/commit-mail.csv \
             --reply-from-patterns @example.com:/^From:.*?@example\.com/,@example.net:/^From:.*@example\.net/

Options:
    -d, --directory=DIR              Load mails from DIR.
    -o, --output-filename=PATH       Store CSV data to PATH.
    -t, --terms=TERM1,TERM2,TERM3,   Analyze commits in these terms.
        --reply-from-patterns=LABEL:PATTERN,...
                                     Reply from address patterns.
    -h, --help                       Print this message and quit.
````

## License

GPL 3.0 or later. See doc/text/gpl-3.0.txt for details.

## Authors

* Kenji Okimoto: `<okimoto@clear-code.com>`
* Kouhei Sutou: `<kou@clear-code.com>`
* Haruka Yoshihara: `<yoshihara@clear-code.com>`

