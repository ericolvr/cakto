"""
Mock RabbitMQ - Envia mensagens de History para o Celery
Uso: python mock_rabbitmq.py
"""
import json
import time
import random
from datetime import datetime
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()

from history.tasks import process_history_message


class MockRabbitMQ:
    """Produtor que envia mensagens de histórico para o Celery via RabbitMQ"""
    
    def __init__(self):
        self.queue_name = "celery"
        self.messages_sent = 0
    
    def generate_history_message(self):
        """Gera mensagem mock para criar um Histórico"""
        return {
            "vigilant_id": random.randint(1, 2),
            "branch_id": random.randint(1, 2),
        }
    
    def send_message(self, message):
        """Envia mensagem para o Celery processar"""
        self.messages_sent += 1
        print(f"\n{'='*60}")
        print(f"Mensagem {self.messages_sent} enviada para Celery")
        print(f"{'='*60}")
        print(json.dumps(message, indent=2, ensure_ascii=False))
        
        # Enviar para o Celery processar via RabbitMQ
        task = process_history_message.delay(message)
        print(f"Task ID: {task.id}")
        print(f"{'='*60}\n")
    
    def start_producer(self, interval=2, total_messages=10):
        """Inicia o produtor de mensagens de History"""
        print(f"\nIniciando Mock Producer - Enviando para Celery via RabbitMQ")
        print(f"Configuracao:")
        print(f"   - Fila Celery: {self.queue_name}")
        print(f"   - Intervalo: {interval}s")
        print(f"   - Total de mensagens: {total_messages}")
        print(f"\n{'='*60}\n")
        
        try:
            for i in range(total_messages):
                message = self.generate_history_message()
                self.send_message(message)
                
                if i < total_messages - 1:
                    print(f"Aguardando {interval}s ate proxima mensagem...\n")
                    time.sleep(interval)
            
            print(f"\nProdutor finalizado!")
            print(f"Total de mensagens enviadas para Celery: {self.messages_sent}")
            print(f"\nVerifique os logs do Celery worker para ver o processamento!")
            print(f"Ou consulte o banco de dados para ver os registros de History criados.")
            
        except KeyboardInterrupt:
            print(f"\n\nProdutor interrompido pelo usuario")
            print(f"Mensagens enviadas: {self.messages_sent}")


def main():
    """Função principal"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Mock RabbitMQ Producer')
    parser.add_argument(
        '--interval',
        type=int,
        default=2,
        help='Intervalo entre mensagens em segundos (padrão: 2)'
    )
    parser.add_argument(
        '--total',
        type=int,
        default=10,
        help='Total de mensagens a enviar (padrão: 10)'
    )
    parser.add_argument(
        '--single',
        action='store_true',
        help='Envia apenas uma mensagem de teste'
    )
    
    args = parser.parse_args()
    
    mock = MockRabbitMQ()
    
    if args.single:
        print("\nEnviando mensagem única de teste...\n")
        mock.send_message(message)
        print(" Mensagem enviada!\n")
    else:
        mock.start_producer(interval=args.interval, total_messages=args.total)


if __name__ == '__main__':
    main()
