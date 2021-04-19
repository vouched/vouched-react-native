
export const faceInstructionToLabel = (instruction, defaultVal) => {
    switch (instruction) {
        case "ONLY_ONE": 
            return 'Only show one face'
        case"MOVE_CLOSER": 
            return 'Too far away'
        case "MOVE_AWAY":
            return 'Too Close to camera'
        case "HOLD_STEADY":
            return 'Hold Steady'
        case "OPEN_MOUTH":
            return 'Smile Wide'
        case "CLOSE_MOUTH":
            return 'Close Mouth'
        case "LOOK_FORWARD":
            return 'Look forward'
        case "BLINK_EYES":
            return 'Slowly Blink'
        default:
            return defaultVal || 'Unknown';
    }
}