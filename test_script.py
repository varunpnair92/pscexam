import sys
sys.path.append('/home/varun/programs/apiapp')

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'apiapp.settings')
django.setup()

from api.models import UserMasterapi, SubscriptionPlan, KeywordNode
from api.serializers import KeywordNodeSerializer
import json

try:
    gold_plan = SubscriptionPlan.objects.filter(name='Gold').first()
    if not gold_plan:
        print("No Gold plan found.")
        sys.exit(0)
    
    roots = KeywordNode.objects.filter(parent__isnull=True).prefetch_related('plans', 'children', 'children__plans')
    
    serializer = KeywordNodeSerializer(
        roots, 
        many=True, 
        context={
            'user_plan_id': gold_plan.id,
            'user_plan_name': gold_plan.name
        }
    )
    
    print("Serialized Output with Gold plan (Node 1 children IDs):")
    for root in serializer.data:
        if root['id'] == 1:
            print([c['id'] for c in root['children']])
except Exception as e:
    import traceback
    traceback.print_exc()

