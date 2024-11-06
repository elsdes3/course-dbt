#!/bin/bash


TAG=${1:-dbt_utils}
ACTION=${2:-built-in}

#  ========== USAGE ==========
# get tests tagged as 'dbt_utils'
# $ ./utils.sh dbt_utils custom
# get tests tagged as 'dbt_expectations'
# $ ./utils.sh dbt_expectations custom
# get built-in and/or custom tests
# $ ./utils.sh '' "built-in"

# run all intermediate models
# $ ./utils.sh 'int_' "run"
# test all marts facts models
# $ ./utils.sh 'fct_' "test"
#  ========== X ==========


if [[ "$ACTION" =~ ^(custom|'built-in')$ ]]; then
    model_paths=(
        `find "greenery/models" -type f -name "*.sql" -printf "%f\n" | \
        sed "s/.*\///; s/\.sql//"`
    )
    for MODEL in "${model_paths[@]}"
    do
        # echo ${MODEL}
        if [[ "$ACTION" == 'built-in' ]]; then
            COUNT=$(tox -e dbt \
                -- ls \
                --select "${MODEL}" | \
                grep -v -E "dbt_expectations|dbt_utils|\.${MODEL}" | \
                grep 'greenery\.' | \
                wc -l)
        else
            COUNT=$(tox -e dbt -- ls --select "${MODEL}" | grep "${TAG}" | wc -l)
        fi
        echo "${MODEL}: ${COUNT}"
    done
else
    model_paths=(
        `find "greenery/models" -type f -name "${TAG}*.sql" -printf "%f\n" | \
        sed "s/.*\///; s/\.sql//" | \
        tr '\n' ' ' | \
        sed 's/,*$//g'`
    )
    # echo "'${model_paths[@]}'"
    tox -e dbt -- ${ACTION} --select "${model_paths[@]}"
fi
