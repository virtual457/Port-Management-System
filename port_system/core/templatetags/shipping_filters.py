from django import template
from decimal import Decimal

register = template.Library()

@register.filter
def length_sum(value, attr):
    """
    Calculates the sum of a specific attribute across a list of dictionaries
    
    Usage: {{ segments|length_sum:'distance' }}
    """
    if not value:
        return 0
    
    total = 0
    for item in value:
        if attr in item:
            try:
                total += Decimal(str(item[attr]))
            except (ValueError, TypeError):
                pass
    
    return total