#!/bin/bash

# set -x


OCP_VERSION=4.12
RESULTS_FOLDER=catalog-check-versions/$(date +"%Y-%m-%d_%H-%M")

# RESULTS_FOLDER=catalog-check-versions/results-2023-11-28_12-16

CATALOG_REDHAT=localhost:5000/redhat/redhat-operator-index:v4.12
CATALOG_CERTIFIED=localhost:5000/redhat/certified-operator-index:v4.12
CATALOG_COMMUNITY=localhost:5000/redhat/community-operator-index:v4.12


echo "###"
echo "# Check log in"
echo "###"

podman login --get-login registry.redhat.io
if [ $? -eq 0 ]; then
    echo "You are logged in!"
else
    echo "Exiting... Please log in to registry.redhat.io"
    exit 1
fi

podman login --get-login localhost:5000
if [ $? -eq 0 ]; then
    echo "You are logged in!"
else
    echo "Exiting... Please log in to localhost:5000 with alvaro:mypass"
    exit 1
fi


echo ""
echo "###"
echo "# Create folder to store results"
echo "###"
mkdir $RESULTS_FOLDER
mkdir $RESULTS_FOLDER/catalogs
mkdir $RESULTS_FOLDER/operators-redhat
mkdir $RESULTS_FOLDER/operators-community
mkdir $RESULTS_FOLDER/operators-certified

echo ""
echo "###"
echo "# Retrieve catalog images for our version"
echo "###"
oc mirror list operators --catalogs --version=$OCP_VERSION | tee $RESULTS_FOLDER/catalogs/catalogs.txt

echo ""
echo "###"
echo "# Retrieve operators for each catalog"
echo "###"
oc mirror list operators --catalog=$CATALOG_REDHAT > $RESULTS_FOLDER/catalogs/operators-redhat.txt
oc mirror list operators --catalog=$CATALOG_CERTIFIED > $RESULTS_FOLDER/catalogs/operators-certified.txt
oc mirror list operators --catalog=$CATALOG_COMMUNITY > $RESULTS_FOLDER/catalogs/operators-community.txt

echo ""
echo "###"
echo "# Retrieve versions for operators in operators-redhat"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[0].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-redhat-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)

for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"

    # List all channels for operator + latest version
    oc mirror list operators --catalog=$CATALOG_REDHAT --package $operator > $RESULTS_FOLDER/operators-redhat/$operator.txt
    channel=$(cat $RESULTS_FOLDER/catalogs/operators-redhat.txt | grep "^$operator" | grep -o '[^ ]*$')
    oc mirror list operators --catalog=$CATALOG_REDHAT --package $operator --channel $channel > $RESULTS_FOLDER/operators-redhat/$operator-$channel.txt
    let COUNTER=COUNTER+1 
done

echo ""
echo "###"
echo "# Retrieve versions for operators in community operators"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[0].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-other-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)

for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"

    # List all channels for operator + latest version
    oc mirror list operators --catalog=$CATALOG_COMMUNITY --package $operator > $RESULTS_FOLDER/operators-community/$operator.txt
    channel=$(cat $RESULTS_FOLDER/catalogs/operators-community.txt | grep "^$operator" | grep -o '[^ ]*$')
    oc mirror list operators --catalog=$CATALOG_COMMUNITY --package $operator --channel $channel > $RESULTS_FOLDER/operators-community/$operator-$channel.txt
    let COUNTER=COUNTER+1 
done



echo ""
echo "###"
echo "# Retrieve versions for operators in certified operators"
echo "###"

CURRENT_OPERATORS=$(yq eval '.mirror.operators[1].packages[].name' catalog-check-versions/ImageSetConfiguration/imageSetConfig-other-operators.yaml)

COUNTER=1
LENGHT=$(echo "$CURRENT_OPERATORS" | wc -l)

for operator in $CURRENT_OPERATORS; do
    echo "[$COUNTER/$LENGHT] Operator: $operator"

    # List all channels for operator + latest version
    oc mirror list operators --catalog=$CATALOG_CERTIFIED --package $operator > $RESULTS_FOLDER/operators-certified/$operator.txt
    channel=$(cat $RESULTS_FOLDER/catalogs/operators-certified.txt | grep "^$operator" | grep -o '[^ ]*$')
    oc mirror list operators --catalog=$CATALOG_CERTIFIED --package $operator --channel $channel > $RESULTS_FOLDER/operators-certified/$operator-$channel.txt
    let COUNTER=COUNTER+1 
done

