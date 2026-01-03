{% macro query_comment(node) %}
    {%- set bigquery_job_labels = var('bigquery_job_labels', {}) -%}

    {%-
        do bigquery_job_labels.update({
            'dbt_node_name': node.name if node is not none else None,
        })
    -%}

    {% do return(tojson(bigquery_job_labels)) %}
{% endmacro %}
