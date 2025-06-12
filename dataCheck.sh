#!/bin/bash

#Author: Rudi Grosman (messed with by Marie Phelan)
#Version: 1.1 
#usage  dataCheck.sh -e -f ./Dataset > output.tsv

OPTIND=1 # Reset incase getopts been used in previous shell.
display_format=true
export_format=false
folder_to_check=''

get_datasetfolder(){
    find $1 -name 'acqus' -exec sed -n -e 's/acqus\(.*\)$/\1/p' {} \;
}

get_title(){
    find $1 -name 'title' -exec sh -c "tr '\n' ' ' < {} " \; 
    # find -name 'title' -exec sh -c  cat {} \; 
}
get_fieldstrength(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$BF1=\ \(.*\)$/\1/p' {} \;
}

get_barcode(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$AUTOPOS=\ \(.*\)$/\1/p' {} \;
}

get_pulseprog(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$PULPROG=\ \(.*\)$/\1/p' {} \;
}

get_overflow(){
    find $1 -name 'overflow_log_dru1.txt' -exec echo 'YES' \;
}

get_timestamp(){
    #find $1 -name 'acqus' -exec sed -n -E 's/^\$\$ ([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}).*$/\1/p' {} \; # This not the actual date for the experiment
    find $1 -name 'acqus' -exec sed -n -e 's/##$DATE=\ \(.*\)$/\1/p' {} \; | xargs -I{} date -d @{} +'%Y/%m/%d - %H:%M:%S'
}

get_temperature(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$TE=\ \(.*\)$/\1/p' {} \;
}

get_receivergain(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$RG=\ \(.*\)$/\1/p' {} \;
}

get_number_of_scans(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$NS=\ \(.*\)$/\1/p' {} \;
}

get_holder_number(){
    find $1 -name 'acqus' -exec sed -n -e 's/##$HOLDER=\ \(.*\)$/\1/p' {} \;
}

get_overflow_number(){
    find $1 -name 'overflow_log_dru1.txt' -exec awk 'END{print $3}' {} \;
}

make_table(){
    if [[ -n $1 ]] && [[ -d $1  ]]
    then
        exp_path=$1
    else
        exp_path='.'
    fi

    echo -e "dataFolder\tField\tExperimentNo\tTimestamp\tTitle\tHolder\tBarcode\tPulseProgram\tTemperature\tRG\tNS\tOverflow\tOverflow #"
    for folder in $exp_path/*; do
        dataset="$(get_datasetfolder $folder)"
	field="$(get_fieldstrength $folder)"
	expn="$(basename $folder)"
        timestamp="$(get_timestamp $folder)"
        title="$(get_title $folder)"
        holder="$(get_holder_number $folder)"
        barcode="$(get_barcode $folder)"
        pulseprog="$(get_pulseprog $folder)"
        temperature="$(get_temperature $folder)"
        rg="$(get_receivergain $folder)"
        ns="$(get_number_of_scans $folder)"
        overflow="$(get_overflow $folder)"
        overflow_number="$(get_overflow_number $folder)"
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$dataset" "$field" "$expn" "$timestamp" "$title" "$holder" "$barcode" "$pulseprog" "$temperature" "$rg" "$ns" "$overflow" "$overflow_number"
    done

}

display_table(){
    make_table "$1" | awk 'NR<2{print ;next}{print | "sort -h"}' | column -t -s $'\t' | grep --color=auto -E '(^.*YES.*|$)'
#    make_table | (sed -u 1q; sort -h) | column -t -s $'\t' | grep --color=auto -E '(^.*YES|$)' # works just a different way 
}


export_table(){
    make_table "$1" | awk 'NR<2{print ;next}{print | "sort -h"}'
#    make_table | (sed -u 1q; sort -h) | column -t -s $'\t' | grep --color=auto -E '(^.*YES|$)' # works just a different way 
}

show_help(){
    echo "Usage: $0 [-h] [-d] [-e] [-f <folder_path>]"
}


while getopts "hdef:" opt; do
    case "$opt" in
        h)
            # echo '-h='${OPTARG}
            show_help
            exit 0
            ;;
        d)
            # echo '-d='${OPTARG}
            display_format=true
            export_format=false
            # shift
            ;;
        e)
            # echo '-e='${OPTARG}
            export_format=true
            display_format=false
            # shift
            ;;
        
        f)
            # echo '-f='"$OPTARG"

            folder_to_check="$OPTARG"
            # echo 'folder_to_check='"$folder_to_check"
            # shift
            ;;            
        *)
            show_help
            exit 0
            ;;
    esac
done

# shift $(($OPTIND-1))



if [[ "$display_format" = true ]]
then
    display_table "$folder_to_check"
    exit 0
fi

if [[ "$export_format" = true ]]
then
    export_table "$folder_to_check"
    exit 0
fi
