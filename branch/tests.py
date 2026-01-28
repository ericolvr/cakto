from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from django.contrib.auth import get_user_model
from .models import Branch

User = get_user_model()


class BranchModelTest(TestCase):
    """Testes para o model Branch"""
    
    def setUp(self):
        self.branch = Branch.objects.create(
            name="Filial Centro",
            description="Filial localizada no centro da cidade"
        )
    
    def test_branch_creation(self):
        """Testa se a branch foi criada corretamente"""
        self.assertEqual(self.branch.name, "Filial Centro")
        self.assertEqual(self.branch.description, "Filial localizada no centro da cidade")
        self.assertIsNotNone(self.branch.id)


class BranchAPITest(APITestCase):
    """Testes para a API de Branch"""
    
    def setUp(self):
        # Criar e autenticar usuário para os testes
        self.user = User.objects.create_user(
            mobile='11999999999',
            password='testpass123'
        )
        self.client.force_authenticate(user=self.user)
        
        self.branch1 = Branch.objects.create(
            name="Filial Norte",
            description="Filial da zona norte"
        )
        self.branch2 = Branch.objects.create(
            name="Filial Sul",
            description="Filial da zona sul"
        )
        
        self.list_url = reverse('branch-list-create')
        self.detail_url = lambda pk: reverse('branch-detail', kwargs={'pk': pk})
    
    def test_list_branches(self):
        """Testa listagem de todas as branches"""
        response = self.client.get(self.list_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        self.assertEqual(response.data[0]['name'], "Filial Norte")
    
    def test_create_branch(self):
        """Testa criação de uma nova branch"""
        data = {
            'name': 'Filial Leste',
            'description': 'Filial da zona leste'
        }
        response = self.client.post(self.list_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Branch.objects.count(), 3)
        self.assertEqual(response.data['name'], 'Filial Leste')
        self.assertEqual(response.data['description'], 'Filial da zona leste')
    
    def test_create_branch_invalid_data(self):
        """Testa criação de branch com dados inválidos"""
        data = {
            'name': '',
            'description': 'Descrição sem nome'
        }
        response = self.client.post(self.list_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Branch.objects.count(), 2)
    
    def test_retrieve_branch(self):
        """Testa busca de uma branch específica"""
        response = self.client.get(self.detail_url(self.branch1.id))
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Filial Norte')
        self.assertEqual(response.data['id'], self.branch1.id)
    
    def test_retrieve_branch_not_found(self):
        """Testa busca de branch inexistente"""
        response = self.client.get(self.detail_url(9999))
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_update_branch_put(self):
        """Testa atualização completa de uma branch (PUT)"""
        data = {
            'name': 'Filial Norte Atualizada',
            'description': 'Nova descrição da filial norte'
        }
        response = self.client.put(
            self.detail_url(self.branch1.id),
            data,
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.branch1.refresh_from_db()
        self.assertEqual(self.branch1.name, 'Filial Norte Atualizada')
        self.assertEqual(self.branch1.description, 'Nova descrição da filial norte')
    
    def test_update_branch_patch(self):
        """Testa atualização parcial de uma branch (PATCH)"""
        data = {
            'name': 'Filial Sul Modificada'
        }
        response = self.client.patch(
            self.detail_url(self.branch2.id),
            data,
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.branch2.refresh_from_db()
        self.assertEqual(self.branch2.name, 'Filial Sul Modificada')
        self.assertEqual(self.branch2.description, 'Filial da zona sul')
    
    def test_delete_branch(self):
        """Testa exclusão de uma branch"""
        response = self.client.delete(self.detail_url(self.branch1.id))
        
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Branch.objects.count(), 1)
        self.assertFalse(Branch.objects.filter(id=self.branch1.id).exists())
