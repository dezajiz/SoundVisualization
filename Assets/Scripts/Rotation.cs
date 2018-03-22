using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Rotation : MonoBehaviour {

	float rotateX;
	float rotateY;
	float rotateZ;
	private Tweener tween; 
	
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

		if (Input.GetKey(KeyCode.Space)) {
			if (tween != null) {
				tween.Kill();
			}
			int scale = Mathf.FloorToInt(Random.Range(1, 3));
			transform.localScale = new Vector3(scale, scale, scale);

			tween = transform.DOScale(new Vector3(0.1f, 0.1f, 0.1f), 0.3f);
		}
	}
}
