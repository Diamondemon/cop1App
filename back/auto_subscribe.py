from weezevent import WEEZEVENT

class SubscriptionException(Exception):
    pass


def subscribe(
    evt_id: int,
    billet_id: int,
    phone: str,
    first_name: str,
    last_name: str,
    email: str
) -> str:
    try:
        barcode = WEEZEVENT.add_participant(
            evt_id=evt_id,
            billet_id=billet_id,
            email=email,
            first_name=first_name,
            last_name=last_name,
            phone=phone,
        )
    except Exception as e:
        raise SubscriptionException('Unknow error') from e
    return barcode

def unsubscribe(
    evt_id: str,
    barcode: str
) -> None:
    try:
        WEEZEVENT.delete_participant(
            evt_id=int(evt_id),
            barcode=barcode
        )
    except Exception as e:
        raise SubscriptionException('Unknow error') from e
