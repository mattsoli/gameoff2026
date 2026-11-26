class_name FeedbackButton
extends Button
## Pulsante che può avere una reazione al mouse tutta sua.
## Precedenza: Feedback Override di questo pulsante -> effetto dello stile del Theme
## (UiSettings.button_feedback_by_style) -> effetto generale (UiSettings.button_feedback).

## Reazione al mouse solo per questo pulsante. Vuoto = si usa quella dello stile o quella generale.
@export var feedback_override: ButtonFeedback
