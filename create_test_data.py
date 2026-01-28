import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()

from django.contrib.auth import get_user_model
from branch.models import Branch
from vigilant.models import Vigilant

User = get_user_model()

def create_test_data():
    print("Criando dados de teste...")
    
    # Criar Branches
    branch1, created = Branch.objects.get_or_create(
        name="Filial Centro",
        defaults={'description': "Filial localizada no centro da cidade"}
    )
    if created:
        print(f"Branch criado: {branch1.name}")
    else:
        print(f"Branch já existe: {branch1.name}")
    
    branch2, created = Branch.objects.get_or_create(
        name="Filial Norte",
        defaults={'description': "Filial localizada na zona norte"}
    )
    if created:
        print(f"Branch criado: {branch2.name}")
    else:
        print(f"Branch já existe: {branch2.name}")
    
    # Criar Users e Vigilantes
    user1, created = User.objects.get_or_create(
        mobile="11999990001",
        defaults={'name': "João Silva", 'is_active': True}
    )
    if created:
        print(f"User criado: {user1.name}")
    else:
        print(f"User já existe: {user1.name}")
    
    vigilant1, created = Vigilant.objects.get_or_create(
        user=user1,
        defaults={'name': "João Silva", 'mobile': "11999990001"}
    )
    if created:
        print(f"Vigilante criado: {vigilant1.name}")
    else:
        print(f"Vigilante já existe: {vigilant1.name}")
    
    user2, created = User.objects.get_or_create(
        mobile="11999990002",
        defaults={'name': "Maria Santos", 'is_active': True}
    )
    if created:
        print(f"User criado: {user2.name}")
    else:
        print(f"User já existe: {user2.name}")
    
    vigilant2, created = Vigilant.objects.get_or_create(
        user=user2,
        defaults={'name': "Maria Santos", 'mobile': "11999990002"}
    )
    if created:
        print(f"Vigilante criado: {vigilant2.name}")
    else:
        print(f"Vigilante já existe: {vigilant2.name}")
    
    print("\nResumo:")
    print(f"  Branches: {Branch.objects.count()}")
    print(f"  Vigilantes: {Vigilant.objects.count()}")
    print(f"  Users: {User.objects.count()}")
    print("\nDados de teste criados com sucesso!")

if __name__ == '__main__':
    create_test_data()
