@tool
extends EditorScript

func _run():
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	var queue : Array
	queue.push_back(root)
	var string_builder : Array
	var skeleton : Skeleton3D
	var ewbik : SkeletonModification3DEWBIK = null
	while not queue.is_empty():
		var front = queue.front()
		var node : Node = front
		if node is Skeleton3D:
			skeleton = node
		if node is SkeletonModification3DEWBIK:
			ewbik = node
		var child_count : int = node.get_child_count()
		for i in child_count:
			queue.push_back(node.get_child(i))
		queue.pop_front()
	if ewbik != null:
		ewbik.free()
	if skeleton == null:
		return
	skeleton.reset_bone_poses()
	ewbik = SkeletonModification3DEWBIK.new()
	skeleton.add_child(ewbik, true)
	ewbik.owner = root
	var godot_to_vrm : Dictionary
	var profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var bone_map : BoneMap = BoneMap.new()
	bone_map.profile = profile
	var bone_vrm_mapping : Dictionary
	ewbik.max_ik_iterations = 10
	var pin_i = 0
	var bones = [
		"Hips", 
#		"Chest", "UpperChest",
#		"LeftShoulder", "RightShoulder",
#		"LeftUpperArm", "RightUpperArm",
#		"LeftLowerArm", "RightLowerArm",
		"LeftHand", "RightHand", 
		"Neck", "Head", 
		"Spine",
#		"LeftUpperLeg", "RightUpperLeg",
#		"LeftLowerLeg", "RightLowerLeg",
		"LeftFoot", "RightFoot"]
	ewbik.pin_count = bones.size()
	for bone_name in bones:
		var bone_index = skeleton.find_bone(bone_name)
		var node_3d : Node3D = Node3D.new()
		node_3d.name = bone_name
		if root.find_child(node_3d.name) == null:
			root.add_child(node_3d)
		node_3d.owner = root
		if bone_name ==  "Hips":
			ewbik.set_pin_depth_falloff(pin_i, 0)
		ewbik.set_pin_bone_name(pin_i, bone_name)
		ewbik.set_pin_depth_falloff(pin_i, 1)
		ewbik.set_pin_direction_priorities(pin_i, Vector3(0.5, 0, 0.5).normalized())
		var bone_id = skeleton.find_bone(bone_name)
		if bone_id == -1:
			pin_i = pin_i + 1
			continue
		var bone_global_pose : Transform3D = skeleton.get_bone_global_rest(bone_id)
		bone_global_pose = skeleton.transform * bone_global_pose
		node_3d.global_transform = bone_global_pose
		var path_string : String = "../" + str(skeleton.get_path_to(root)) + "/" + bone_name
		ewbik.set_pin_nodepath(pin_i, NodePath(path_string))
		pin_i = pin_i + 1
	# Female https://pubmed.ncbi.nlm.nih.gov/32644411/
#	ewbik.set_constraint_count(bones.size())
#	for constraint_i in range(bones.size()):
#		var bone_name : String = bones[constraint_i]
#		ewbik.set_constraint_name(constraint_i, bone_name)
#		ewbik.set_kusudama_twist(constraint_i, Vector2(0, 120))
##		# https://pubmed.ncbi.nlm.nih.gov/32644411/
#		if bone_name in ["LeftHand", "LeftFoot"]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(0, 120))
#		if bone_name in ["RightFoot", "RightHand"]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(0, 120))
#		if bone_name in ["Chest", "UpperChest"]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(0, 50))
#		if bone_name in ["Hips"]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(30, -30))
#		if bone_name in ["Spine",]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(0, 1))
#		if bone_name in ["LeftShoulder", "RightShoulder",]:
#			ewbik.set_kusudama_twist(constraint_i, Vector2(0, 5))
#		ewbik.set_kusudama_limit_cone_count(constraint_i, 1)
#		ewbik.set_kusudama_limit_cone_center(constraint_i, 0, Vector3(0, 1, 0))
#		ewbik.set_kusudama_limit_cone_radius(constraint_i, 0, rad_to_deg(PI))
