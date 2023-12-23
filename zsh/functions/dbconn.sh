#!/bin/zsh

# Define a function to generate the list of database names for auto-completion
function _ssh_db_complete() {
    local databases=("redshift" "pg")

    _describe 'values' databases
}

# Register the function for auto-completion
compdef _ssh_db_complete dbconn

# The main function to open an SSH connection to a database
function dbconn() {
    local db_name="$1"
    # local ssh_command="ssh -p <port_number> user@hostname"  # Replace <port_number> with the appropriate port
    local ssh_command="ssh -T -nNC -o ServerAliveInterval=120" 
    # local tail_pg=":glc-postgres-01.c3bg4450zvkn.eu-west-1.rds.amazonaws.com:5432 above@jumpbox.gualaclosures.com -v"

    case "$db_name" in
        "pg")
            ssh_command+=" -L 5432:glc-postgres-01.c3bg4450zvkn.eu-west-1.rds.amazonaws.com:5432 above@jumpbox.gualaclosures.com -v"
            ;;
        "redshift")
            ssh_command+=" -L 5439:glc-redshift-1.cfhuma3novjj.eu-west-1.redshift.amazonaws.com:5439 above@jumpbox.gualaclosures.com -v"
            ;;
        *)
            echo "Unsupported database: $db_name"
            return 1
            ;;
    esac


    echo "Connecting to $db_name..."
    eval "$ssh_command"
}


# ssh -T -nNC -o ServerAliveInterval=120 -L 5439:glc-redshift-1.cfhuma3novjj.eu-west-1.redshift.amazonaws.com:5432 above@jumpbox.gualaclosures.com -v
