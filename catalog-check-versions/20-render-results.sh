#!/bin/bash

# set -x

CATALOG_REDHAT=localhost:5000/redhat/redhat-operator-index:v4.12
CATALOG_CERTIFIED=localhost:5000/redhat/certified-operator-index:v4.12
CATALOG_COMMUNITY=localhost:5000/redhat/community-operator-index:v4.12

if [ $# -eq 0 ]; then 
    echo "No execution folder provided. Please provide the folder name that you want to mirror to the internal registry"
    echo ""
    echo "Syntax:  $0 <Folder Name>"
    echo "Example: $0 2023-11-30_09-25"
    exit 1
fi
RESULTS_FOLDER=catalog-check-versions/$1
mkdir $RESULTS_FOLDER/rendered
mkdir $RESULTS_FOLDER/results
rm $RESULTS_FOLDER/rendered/*
rm $RESULTS_FOLDER/results/*

echo ""
echo "###"
echo "# Retrieve versions for operators in operators-redhat"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[0].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-redhat-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)

for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"
    export operator
    export channel=$(cat $RESULTS_FOLDER/catalogs/operators-redhat.txt | grep "^$operator" | grep -o '[^ ]*$')
    export full_version=$(cat $RESULTS_FOLDER/operators-redhat/$operator.txt | grep -n $channel | tail -n 1 | grep -o '[^ ]*$')
    export version=$(echo $full_version | sed 's/.*\.v//' )

    yq --null-input -I=6 '
                    (.[0].name = env(operator)) | 
                    (.[0].channels[0].name = env(channel)) | 
                    (.[0].channels[0].maxVersion = env(version)) | 
                    (.[0].channels[0].minVersion = env(version))' >> $RESULTS_FOLDER/rendered/operators-redhat.yaml

    let COUNTER=COUNTER+1 
done


echo ""
echo "###"
echo "# Retrieve versions for operators in operators-community"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[0].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-other-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)


for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"
    export operator
    export channel=$(cat $RESULTS_FOLDER/catalogs/operators-community.txt | grep "^$operator" | grep -o '[^ ]*$')
    export full_version=$(cat $RESULTS_FOLDER/operators-community/$operator.txt | grep -n $channel | tail -n 1 | grep -o '[^ ]*$')
    export version=$(echo $full_version | sed 's/.*\.v//' )

    yq --null-input -I=6 '
                    (.[0].name = env(operator)) | 
                    (.[0].channels[0].name = env(channel)) | 
                    (.[0].channels[0].maxVersion = env(version)) | 
                    (.[0].channels[0].minVersion = env(version))' >> $RESULTS_FOLDER/rendered/operators-community.yaml

    let COUNTER=COUNTER+1 
done



echo ""
echo "###"
echo "# Retrieve versions for operators in operators-certified"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[1].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-other-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)


for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"
    export operator
    export channel=$(cat $RESULTS_FOLDER/catalogs/operators-certified.txt | grep "^$operator" | grep -o '[^ ]*$')
    export full_version=$(cat $RESULTS_FOLDER/operators-certified/$operator.txt | grep -n $channel | tail -n 1 | grep -o '[^ ]*$')
    export version=$(echo $full_version | sed 's/.*\.v//' )

    yq --null-input -I=6 '
                    (.[0].name = env(operator)) | 
                    (.[0].channels[0].name = env(channel)) | 
                    (.[0].channels[0].maxVersion = env(version)) | 
                    (.[0].channels[0].minVersion = env(version))' >> $RESULTS_FOLDER/rendered/operators-certified.yaml

    let COUNTER=COUNTER+1 
done