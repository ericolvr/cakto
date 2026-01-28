"""
Mock RabbitMQ - Simula envio de mensagens de History
Uso: python mock_rabbitmq.py
"""
import json
import time
import random
from datetime import datetime


class MockRabbitMQ:
    """Simula um produtor RabbitMQ enviando mensagens de histórico"""
    
    def __init__(self):
        self.queue_name = "history_queue"
        self.messages_sent = 0
    
    def generate_history_message(self):
        """Gera mensagem mock para criar um Histórico"""
        return {
            "type": "create_history",
            "data": {
                "vigilant_id": random.randint(1, 5),
                "branch_id": random.randint(1, 5),
            },
            "timestamp": datetime.now().isoformat(),
            "message_id": f"msg_{self.messages_sent + 1}"
        }
    
    def send_message(self, message):
        """Simula envio de mensagem para a fila"""
        self.messages_sent += 1
        print(f"\n{'='*60}")
        print(f"Mensagem {self.messages_sent} enviada para '{self.queue_name}'")
        print(f"{'='*60}")
        print(json.dumps(message, indent=2, ensure_ascii=False))
        print(f"{'='*60}\n")
        
        # Salvar em arquivo para o consumer processar
        with open('history_messages.json', 'a') as f:
            f.write(json.dumps(message) + '\n')
    
    def start_producer(self, interval=2, total_messages=10):
        """Inicia o produtor de mensagens de History"""
        print(f"\nIniciando Mock RabbitMQ Producer - History")
        print(f"Configuracao:")
        print(f"   - Fila: {self.queue_name}")
        print(f"   - Intervalo: {interval}s")
        print(f"   - Total de mensagens: {total_messages}")
        print(f"\n{'='*60}\n")
        
        # Limpar arquivo de mensagens
        open('history_messages.json', 'w').close()
        
        try:
            for i in range(total_messages):
                message = self.generate_history_message()
                self.send_message(message)
                
                if i < total_messages - 1:
                    print(f"Aguardando {interval}s ate proxima mensagem...\n")
                    time.sleep(interval)
            
            print(f"\nProdutor finalizado!")
            print(f"Total de mensagens de History enviadas: {self.messages_sent}")
            print(f"Mensagens salvas em: history_messages.json")
            print(f"\nExemplo de mensagem:")
            print(json.dumps(self.generate_history_message(), indent=2, ensure_ascii=False))
            
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
        print("\n📨 Enviando mensagem única de teste...\n")
        message = mock.generate_branch_message()
        mock.send_message(message)
        print(" Mensagem enviada!\n")
    else:
        mock.start_producer(interval=args.interval, total_messages=args.total)


if __name__ == '__main__':
    main()
