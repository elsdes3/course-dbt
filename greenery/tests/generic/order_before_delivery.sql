{% test order_before_delivery(model, column_name, field) %}


   select *
   from {{ model }}
   where {{ field }} < {{ column_name }}


{% endtest %}
