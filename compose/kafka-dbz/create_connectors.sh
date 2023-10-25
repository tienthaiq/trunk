set -eux;
for f in connectors/*.json; do
    filename="${f#connectors/}"
    connector_name="${filename%.json}"

    curl -i -X DELETE "http://localhost:8083/connectors/${connector_name}";
    curl -i -X POST http://localhost:8083/connectors/ \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
        -d @$f;
done