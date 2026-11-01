import Foundation

enum ExerciseLibrary {
    static let all: [Exercise] = [
        Exercise(id: "wall-push-up", name: "Wall push-up", pattern: .push, level: 1, loads: [.shoulders, .wrists], isJump: false, isLunge: false, cue: "Hands on the wall, body in one line."),
        Exercise(id: "knee-push-up", name: "Knee push-up", pattern: .push, level: 3, loads: [.shoulders, .wrists], isJump: false, isLunge: false, cue: "Knees down, lower the chest, then press."),
        Exercise(id: "push-up", name: "Push-up", pattern: .push, level: 5, loads: [.shoulders, .wrists], isJump: false, isLunge: false, cue: "Straight body, chest toward the floor."),
        Exercise(id: "sit-to-stand", name: "Sit to stand", pattern: .squat, level: 1, loads: [.knees], isJump: false, isLunge: false, cue: "Stand up from a chair, then sit back."),
        Exercise(id: "squat", name: "Squat", pattern: .squat, level: 3, loads: [.knees], isJump: false, isLunge: false, cue: "Sit the hips back, then stand."),
        Exercise(id: "reverse-lunge", name: "Reverse lunge", pattern: .squat, level: 4, loads: [.knees], isJump: false, isLunge: true, cue: "Step back and lower the back knee."),
        Exercise(id: "jump-squat", name: "Jump squat", pattern: .squat, level: 5, loads: [.knees], isJump: true, isLunge: false, cue: "Squat, then leave the floor."),
        Exercise(id: "glute-bridge", name: "Glute bridge", pattern: .hinge, level: 1, loads: [], isJump: false, isLunge: false, cue: "Press the hips up, then lower."),
        Exercise(id: "hip-hinge", name: "Hip hinge", pattern: .hinge, level: 3, loads: [.lowerBack], isJump: false, isLunge: false, cue: "Soft knees, push the hips back."),
        Exercise(id: "single-leg-hinge", name: "Single-leg hinge", pattern: .hinge, level: 5, loads: [.knees, .lowerBack], isJump: false, isLunge: false, cue: "One foot down, hinge until the back is long."),
        Exercise(id: "dead-bug", name: "Dead bug", pattern: .core, level: 1, loads: [], isJump: false, isLunge: false, cue: "Low back stays down as the arm and leg reach."),
        Exercise(id: "plank", name: "Plank", pattern: .core, level: 3, loads: [.wrists, .shoulders], isJump: false, isLunge: false, cue: "Hold a straight line from head to heels."),
        Exercise(id: "mountain-climber", name: "Mountain climber", pattern: .core, level: 5, loads: [.wrists], isJump: true, isLunge: false, cue: "Drive one knee in, then the other."),
        Exercise(id: "open-book", name: "Open book", pattern: .mobility, level: 1, loads: [], isJump: false, isLunge: false, cue: "Lie on your side and open the top arm."),
        Exercise(id: "thoracic-rotation", name: "Thoracic rotation", pattern: .mobility, level: 3, loads: [], isJump: false, isLunge: false, cue: "Turn the chest, keep the hips quiet."),
        Exercise(id: "inchworm", name: "Inchworm", pattern: .mobility, level: 5, loads: [.wrists], isJump: false, isLunge: false, cue: "Walk the hands out, then the feet in.")
    ]
}
