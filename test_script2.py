import sys
import os
import django

sys.path.append('/home/varun/programs/apiapp')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'apiapp.settings')
django.setup()

from api.models import UserMasterapi, SubscriptionPlan, KeywordNode
from api.serializers import KeywordNodeSerializer

plan = SubscriptionPlan.objects.filter(name='Gold').first()
if not plan:
    print("No Gold plan")
    sys.exit(0)

roots = KeywordNode.objects.filter(parent__isnull=True)
serializer = KeywordNodeSerializer(
    roots, 
    many=True, 
    context={'user_plan_id': plan.id, 'user_plan_name': plan.name}
)

def find_node(nodes, target_name):
    for n in nodes:
        if n['name'] == target_name:
            return True
        if n.get('children'):
            if find_node(n['children'], target_name):
                return True
    return False

data = serializer.data
print("Found STUDY:", find_node(data, 'STUDY'))
print("Found booster:", find_node(data, 'booster'))

