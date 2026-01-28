from celery import shared_task
import logging

logger = logging.getLogger(__name__)


@shared_task
def process_history_message(data):
    """
    Task Celery para processar mensagens de History do RabbitMQ
    
    Args:
        data (dict): Dados da mensagem contendo vigilant_id e branch_id
    
    Returns:
        dict: Resultado do processamento
    """
    from .models import History
    from vigilant.models import Vigilant
    from branch.models import Branch
    
    try:
        vigilant_id = data.get('vigilant_id')
        branch_id = data.get('branch_id')
        
        logger.info(f"Processando History: vigilant_id={vigilant_id}, branch_id={branch_id}")
        
        # Verificar se vigilant e branch existem
        try:
            vigilant = Vigilant.objects.get(id=vigilant_id)
            branch = Branch.objects.get(id=branch_id)
        except Vigilant.DoesNotExist:
            error_msg = f"Vigilant com id={vigilant_id} nao encontrado"
            logger.error(error_msg)
            return {'status': 'error', 'message': error_msg}
        except Branch.DoesNotExist:
            error_msg = f"Branch com id={branch_id} nao encontrado"
            logger.error(error_msg)
            return {'status': 'error', 'message': error_msg}
        
        # Criar registro de History
        history = History.objects.create(
            vigilant=vigilant,
            branch=branch
        )
        
        logger.info(f"History criado com sucesso: id={history.id}")
        
        return {
            'status': 'success',
            'history_id': history.id,
            'vigilant_id': vigilant_id,
            'branch_id': branch_id,
            'created_at': history.created_at.isoformat()
        }
        
    except Exception as e:
        error_msg = f"Erro ao processar mensagem: {str(e)}"
        logger.error(error_msg, exc_info=True)
        return {'status': 'error', 'message': error_msg}


@shared_task
def process_history_batch(messages):
    """
    Processa um lote de mensagens de History
    
    Args:
        messages (list): Lista de mensagens para processar
    
    Returns:
        dict: Estatísticas do processamento
    """
    results = {
        'total': len(messages),
        'success': 0,
        'errors': 0,
        'details': []
    }
    
    for msg in messages:
        result = process_history_message(msg.get('data', {}))
        
        if result.get('status') == 'success':
            results['success'] += 1
        else:
            results['errors'] += 1
        
        results['details'].append(result)
    
    logger.info(f"Batch processado: {results['success']} sucesso, {results['errors']} erros")
    
    return results
