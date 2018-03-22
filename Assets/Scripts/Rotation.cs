using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour {

	float rotateX;
	float rotateY;
	float rotateZ;
	
	void Start () {
		rotateX = Random.Range(1, 360);
		rotateY = Random.Range(1, 360);
		rotateZ = Random.Range(1, 360);
	}
	// Update is called once per frame
	void Update () {
		gameObject.transform.rotation = Quaternion.Euler(rotateX, rotateY, rotateZ);
		rotateX += 2;
		rotateY += 2;
		rotateZ += 2;
	}
}
