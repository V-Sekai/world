import { vec3,quat,mat4 } from "../gl-matrix.js";
import { SwingTwist, DecodeVideoFloat, orthogonalize } from "./ShaderImpl.js";

export class MotionPlayer {
	// [SerializeField]
	// public RenderTexture motionBuffer;
	// public Animator animator;
	// public SkinnedMeshRenderer shapeRenderer;
	// public int layer;
	// public float humanScale = -1;

	// [Header("Advanced settings")]
	// public bool applyHumanPose;
	// public Vector2Int resolution = new Vector2Int(80,45);
	// public Vector3Int tileSize = new Vector3Int(2,1,3);
	// public int tileRadix = 3;
	
	// [System.NonSerialized]
	// private GPUReader gpuReader = new GPUReader();
	// [System.NonSerialized]
	// private Skeleton skeleton;
	// [System.NonSerialized]
	// private MotionDecoder decoder;
	
	OnEnable() {
		this.skeleton = new Skeleton(gltf);
		const layout = new MotionLayout(this.skeleton);
		this.decoder = new MotionDecoder(layout);
	}
	Update() {
		avatar.motionDecoder.Update({width:40, height:45, getData:motionDec.readPixels.bind(motionDec)}, avatar.layer);

		var request = gpuReader.Request(motionBuffer);
		if(request != null && !request.Value.hasError) {
			decoder.Update(request.Value, layer);
			if(applyHumanPose)
				ApplyHumanPose();
			else
				ApplyTransform();
			ApplyBlendShape();
		}
	}

	// const float shapeWeightEps = 0.1f;
	// private HumanPoseHandler poseHandler;
	// private HumanPose humanPose;
	// private Vector3[] swingTwists;
	ApplyScale() {
		if(humanScale != 0)
			skeleton.root.localScale = (humanScale > 0 ? humanScale : decoder.motions[0].s)
				/ skeleton.humanScale * Vector3.one;
	}
	ApplyTransform() {
		ApplyScale();
		skeleton.bones[0].position = skeleton.root.TransformPoint(
			decoder.motions[0].t / (decoder.motions[0].s/skeleton.humanScale));
		for(int i=0; i<skeleton.bones.Length; i++)
			if(skeleton.bones[i]) {
				var axes = skeleton.axes[i];
				if(!skeleton.dummy[i])
					skeleton.bones[i].localRotation = axes.preQ * decoder.motions[i].q * Quaternion.Inverse(axes.postQ);
				else // TODO: this assumes non-dummy precedes dummy bone and breaks for missing Neck
					skeleton.bones[i].localRotation *= axes.postQ * decoder.motions[i].q * Quaternion.Inverse(axes.postQ);
			}
	}
}